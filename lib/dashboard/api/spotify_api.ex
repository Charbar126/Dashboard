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

  # def authorize(lat \\ 40.9645, lon \\ -76.8844, units \\ "imperial") do
  #   url =
  #     "#{Dotenv.get("OPEN_WEATHER_API_URL")}?lat=#{lat}&lon=#{lon}&appid=#{Dotenv.get("OPEN_WEATHER_API_KEY")}&units=#{units}"

  #   case HTTPoison.get(url) do
  #     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
  #       {:ok, Jason.decode!(body)}

  #     {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
  #       {:error, "Received status code #{status_code}: #{body}"}

  #     {:error, %HTTPoison.Error{reason: reason}} ->
  #       {:error, "Request failed: #{inspect(reason)}"}
  #   end
  # end
end
