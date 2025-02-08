defmodule Dashboard.Api.SpotifyApi do
  # Might need to be in widget rather than api
  def authorize_url() do
    url =
      "https://accounts.spotify.com/authorize" <>
        "?client_id=#{Dotenv.get("SPOTIFY_CLIENT_ID")}" <>
        "&response_type=code" <>
        "&redirect_uri=#{Dotenv.get("SPOTIFY_REDIRECT_URI")}" <>
        "&scope=user-read-private%20user-read-email%20user-read-playback-state%20user-modify-playback-state"

    url
  end

  def exchange_code_for_token(code) do
    body = URI.encode_query()
  end
end
