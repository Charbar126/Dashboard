defmodule Dashboard.Api.SpotifyApi do
  @doc """
  Generates a URL for Spotify authorization page
  Query Parameter:
    Cleint ID: Spotify Client ID - Defined in .env
    Response Type: code - Set to code for general access
    Redirect URI: Spotify Redirect URI - Defined in .env
    state: A unique and non-guessable value used to prevent cross-site request forgery attack
  """
  def gen_auth_url(state) do
    url =
      "https://accounts.spotify.com/authorize" <>
        "?client_id=#{Dotenv.get("SPOTIFY_CLIENT_ID")}" <>
        "&response_type=code" <>
        "&redirect_uri=#{URI.encode(Dotenv.get("SPOTIFY_REDIRECT_URI"))}" <>
        "&scope=#{Dotenv.get("SPOTIFY_SCOPE")}"

    "&state=#{state}"
    url
  end

  def exchange_code_for_token(code) do
    auth_string = "#{Dotenv.get("SPOTIFY_CLIENT_ID")}:#{Dotenv.get("SPOTIFY_CLIENT_SECERT")}"
    encoded_auth = Base.encode64(auth_string)

    body =
      URI.encode_query(%{
        code: code,
        redirect_uri: Dotenv.get("SPOTIFY_REDIRECT_URI"),
        grant_type: "authorization_code"
      })

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Authorization", "Basic #{encoded_auth}"}
    ]

    url = Dotenv.get("SPOTIFY_TOKEN_URL")

    HTTPoison.post(url, body, headers)
  end
end
