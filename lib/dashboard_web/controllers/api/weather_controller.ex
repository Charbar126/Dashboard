defmodule DashboardWeb.Api.WeatherController do
  use DashboardWeb, :controller
  alias HTTPoison

  def fetch_current_weather(conn, _params) do
    # Need to remove API and get location through geolocation NOTE: Also need to have settings for units and such
    url =
      "https://api.openweathermap.org/data/2.5/weather?lat=40.964527&lon=76.884407&appid=09d790f7f1c9d65033ebd09f46ac771f&units=imperial"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        json(conn, Jason.decode!(body))

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        json(conn, %{error: "Received status code #{status_code}", response: Jason.decode!(body)})

      {:error, %HTTPoison.Error{reason: reason}} ->
        json(conn, %{error: "Request failed: #{inspect(reason)}"})
    end
  end

  # def fetch_weather_icon(conn, icon_name) do
  #   url = "https://openweathermap.org/img/wn/#{icon_name}@2x.png"

  #   case HTTPoison.get(url) do
  #     {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
  #       conn
  #       |> put_resp_content_type(get_content_type(headers))
  #       |> send_resp(200, body)

  #     {:ok, %HTTPoison.Response{status_code: status_code}} ->
  #       json(conn, %{error: "Failed to fetch icon, status code: #{status_code}"})

  #     {:error, %HTTPoison.Error{reason: reason}} ->
  #       json(conn, %{error: "Request failed: #{inspect(reason)}"})
  #   end
  # end
end
