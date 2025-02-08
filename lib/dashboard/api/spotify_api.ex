defmodule Dashboard.Api.SpotifyApi do

  def get_current_weather(lat \\ 40.9645, lon \\ -76.8844, units \\ "imperial") do
    url =
      "#{Dotenv.get("OPEN_WEATHER_API_URL")}?lat=#{lat}&lon=#{lon}&appid=#{Dotenv.get("OPEN_WEATHER_API_KEY")}&units=#{units}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Received status code #{status_code}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end
  
end
