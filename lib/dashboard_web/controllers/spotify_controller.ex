defmodule DashboardWeb.SpotifyController do
  use DashboardWeb, :controller
  alias Dashboard.Api.SpotifyApi
  alias Dashboard.SpotifyTokens

  @state :string

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
    case SpotifyApi.exchange_code_for_token(code) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        token_data = Jason.decode!(body)
        formatted_data = format_token_data(token_data)

        case SpotifyTokens.create_spotify_token(formatted_data) do
          {:ok, _spotify_token} ->
            IO.inspect(formatted_data, label: "Stored Token Data")
            conn |> redirect(to: "/")

          {:error, changeset} ->
            IO.inspect(changeset, label: "Failed to store token")
            conn |> redirect(to: "/error")
        end

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        IO.inspect({status, body}, label: "Error response from Spotify")
        conn |> redirect(to: "/error")

      {:error, reason} ->
        IO.inspect(reason, label: "HTTP request error")
        conn |> redirect(to: "/error")
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
  Checks and retrieves the stored Spotify token (for debugging purposes).
  """
  def check_spotify_token() do
    IO.inspect(SpotifyTokens.get_spotify_token!(0))
  end
end
