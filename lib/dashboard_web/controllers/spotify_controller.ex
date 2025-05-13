defmodule DashboardWeb.SpotifyController do
  import Ecto.Query
  use DashboardWeb, :controller
  alias Dashboard.Api.SpotifyApi
  alias Dashboard.SpotifyTokens
  require Logger

  @doc """
  Redirects the user to the Spotify authorization page.
  """
  def authenticate_user(conn, _params) do
    state = generate_random_string(16)
    url = SpotifyApi.gen_auth_url(state)

    conn
    |> redirect(external: url)
  end

  @doc """
  Callback for the Spotify authorization page.
  NOTE: Need to check state
  """
  def callback_user_auth(conn, %{"code" => code}) do
    # NOTE: Need to store spotify token in the database
    case SpotifyApi.exchange_code_for_token(code) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        token_data = Jason.decode!(body)
        formatted_data = format_token_data(token_data)
        SpotifyTokens.create_spotify_token(formatted_data)

        conn
        |> redirect(to: "/")

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        IO.inspect({status, body}, label: "Error response from Spotify")
        conn |> redirect(to: "/error")

      {:error, reason} ->
        IO.inspect(reason, label: "HTTP request error")
        conn |> redirect(to: "/error")
    end
  end

  @doc """
  Refreshes the Spotify access token using the refresh token.
  """
  def refresh_spotify_token() do
    case get_recent_spotify_token() do
      %{refresh_token: refresh_token} when not is_nil(refresh_token) ->
        case SpotifyApi.refresh_access_token(refresh_token) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            token_data = Jason.decode!(body)
            formatted_data = format_token_data(token_data)
            SpotifyTokens.create_spotify_token(formatted_data)
            {:ok, formatted_data.access_token}

          {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
            IO.inspect({status, body}, label: "Error response from Spotify")
            {:error, %{status: status, body: body}}

          {:error, reason} ->
            IO.inspect(reason, label: "HTTP request error")
            {:error, reason}
        end

      _ ->
        {:error, :no_token}
    end
  end

  def get_recent_spotify_token do
    Dashboard.SpotifyTokens.get_latest_spotify_token()
  end

  def get_profile(access_token) do
    case Dashboard.Api.SpotifyApi.get_profile(access_token) do
      {:ok, profile} ->
        profile

      {:error, reason} ->
        IO.inspect(reason, label: "Failed to fetch Spotify profile")
        nil
    end
  end

  def get_player(access_token) do
    case Dashboard.Api.SpotifyApi.get_player(access_token) do
      {:ok, player} ->
        player

      {:error, reason} ->
        IO.inspect(reason, label: "Failed to fetch Spotify player")
        nil
    end
  end

  @doc """
  Formats the token data for insertion into the database.
  """
  defp format_token_data(token_data) do
    %{
      access_token: token_data["access_token"],
      refresh_token: token_data["refresh_token"],
      expires_at: DateTime.utc_now() |> DateTime.add(token_data["expires_in"], :second)
    }
  end

  @doc """
  Generates a random string for the Spotify authorization state parameter.
  """
  defp generate_random_string(length) when length > 0 do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  @doc """
  Checks and retrieves the stored Spotify token.
  """
  def is_spotify_token_expired() do
    expire_time = SpotifyTokens.get_latest_spotify_token().expires_at

    case DateTime.compare(expire_time, DateTime.utc_now()) do
      # expired
      :lt -> true
      # still valid
      _ -> false
    end
  end
end
