defmodule Dashboard.Api.GoogleApi do
  def gen_auth_url(state) do
    url =
      "https://accounts.google.com/o/oauth2/v2/auth" <>
        "?client_id=#{Dotenv.get("GOOGLE_CLIENT_ID")}" <>
        "&response_type=code" <>
        "&redirect_uri=#{URI.encode(Dotenv.get("GOOGLE_REDIRECT_URI"))}" <>
        "&scope=#{Dotenv.get("GOOGLE_SCOPE")}" <>
        "&state=#{state}"

    IO.inspect(url)

    url
  end

  def exchange_code_for_token(code)do
    body =
      URI.encode_query(%{
        code: code,
        redirect_uri: Dotenv.get("GOOGLE_REDIRECT_URI"),
        client_id: Dotenv.get("GOOGLE_CLIENT_ID"),
        client_secret: Dotenv.get("GOOGLE_CLIENT_SECRET"),
        grant_type: "authorization_code"
      })

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    url = Dotenv.get("GOOGLE_TOKEN_URL")

    HTTPoison.post(url, body, headers)
  end

  # def refresh_access_token(refresh_token) do

  # end
end
