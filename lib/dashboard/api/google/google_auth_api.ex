defmodule Dashboard.Api.Google.GoogleAuthAPI do
  def gen_auth_url() do
    "https://accounts.google.com/o/oauth2/v2/auth" <>
      "?client_id=#{Dotenv.get("GOOGLE_CLIENT_ID")}" <>
      "&response_type=code" <>
      "&redirect_uri=#{URI.encode(Dotenv.get("GOOGLE_REDIRECT_URI"))}" <>
      "&scope=#{URI.encode(Dotenv.get("GOOGLE_OAUTH_SCOPES"))}" <>
      "&access_type=offline" <>
      "&prompt=consent"
  end

  def exchange_code_for_token(code) do
    body =
      URI.encode_query(%{
        code: code,
        client_id: Dotenv.get("GOOGLE_CLIENT_ID"),
        client_secret: Dotenv.get("GOOGLE_CLIENT_SECRET"),
        redirect_uri: Dotenv.get("GOOGLE_REDIRECT_URI"),
        grant_type: "authorization_code"
      })

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    IO.inspect(client_secret: Dotenv.get("GOOGLE_CLIENT_SECRET"))
    url = "https://oauth2.googleapis.com/token"
    HTTPoison.post(url, body, headers)
  end

  @doc """
  Refreshes the access token using the refresh token.
  #NEED to add in error handling
  """
  def refresh_access_token(refresh_token) do
    url = Dotenv.get("GOOGLE_TOKEN_URL")

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    body =
      URI.encode_query(%{
        client_id: Dotenv.get("GOOGLE_CLIENT_ID"),
        client_secret: Dotenv.get("GOOGLE_CLIENT_SECRET"),
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      })

    HTTPoison.post(url, body, headers)
  end
end
