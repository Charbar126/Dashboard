defmodule DashboardWeb.WeatherController do
  use DashboardWeb, :controller
  alias Dashboard.Api.WeatherApi, as: WeatherAPI

  def fetch_current_weather(conn, _params) do
    case WeatherAPI.get_current_weather(40.9645, -76.8844, "imperial") do
      {:ok, weather_data} ->
        json(conn, weather_data)

      {:error, reason} ->
        json(conn, %{error: "Failed to fetch weather: #{reason}"})
    end
  end
end
