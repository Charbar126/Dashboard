defmodule DashboardWeb.SpotifyController do
  use DashboardWeb, :controller
  alias Dashboard.Api.SpotifyApi

  @state :string

  def authenticate_user(conn, _params) do
    state = generate_random_string(16)
    url = SpotifyApi.gen_auth_url(state)
    IO.inspect(url)

    conn
    # Redirect to Spotify auth page
    |> redirect(external: url)
  end

  # Need to watch for edge case of string without callback
  def callback_user_auth(conn, %{"code" => code}) do
    case SpotifyApi.exchange_code_for_token(code) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # Parse the response (likely JSON) to extract the token
        token_data = Jason.decode!(body)
        # Do something with the token, e.g., store it in the session
        IO.inspect(token_data, label: "Token data")

        conn
        # Redirect to a safe page
        |> redirect(to: "/")

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        # Handle non-200 responses
        IO.inspect({status, body}, label: "Error response from Spotify")

        conn
        |> redirect(to: "/")

      {:error, reason} ->
        IO.inspect(reason, label: "HTTP request error")

        conn
        |> redirect(to: "/")
    end
  end

  defp generate_random_string(length) when length > 0 do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end
end
