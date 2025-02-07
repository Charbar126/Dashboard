defmodule Dashboard.Api.WeatherApi do
  alias HTTPoison

  @api_key "09d790f7f1c9d65033ebd09f46ac771f"
  @base_url "https://api.openweathermap.org/data/2.5/weather"

  def get_current_weather(lat \\ 40.9645, lon \\ -76.8844, units \\ "imperial") do
    url = "#{@base_url}?lat=#{lat}&lon=#{lon}&appid=#{@api_key}&units=#{units}"

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
