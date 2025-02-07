defmodule DashboardWeb.Api.WeatherControllerTest do
  use DashboardWeb.ConnCase, async: true
  alias HTTPoison

  # Need to add more
  describe "Weather API" do
    test "GET /api/current_weather returns a JSON response", %{conn: conn} do
      conn = get(conn, "/api/current_weather")
      IO.inspect(json_response(conn, 200))
    end

    test "GET /api/weather_icon returns a weather icon", %{conn: conn} do
      conn = get(conn, "/api/current_weather")
      IO.inspect(json_response(conn, 200))
    end
  end
end
