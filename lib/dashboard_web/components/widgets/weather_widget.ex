defmodule DashboardWeb.Components.Widgets.WeatherWidget do
  @moduledoc """
  A LiveComponent that displays current weather data in a styled, clean layout.
  """

  use Phoenix.LiveComponent
  import DashboardWeb.Ui.Card
  alias Dashboard.Api.WeatherApi, as: WeatherAPI

  @impl true
  def update(_assigns, socket) do
    case WeatherAPI.get_current_weather() do
      {:ok, weather_data} ->
        {:ok, assign(socket, weather: format_weather(weather_data))}

      {:error, _reason} ->
        {:ok, assign(socket, weather: %{error: "Failed to fetch weather data"})}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.card height="h-full" width="w-full" padding="p-4" background="bg-white dark:bg-zinc-800">
        <%= if @weather[:error] do %>
          <p class="text-red-500">Error: {@weather[:error]}</p>
        <% else %>
          <!-- Location on top -->
          <div class="text-center text-xl font-bold mb-2">
            {@weather.location}
          </div>

    <!-- Main Section: Temp + Weather Stats -->
          <div class="flex flex-col items-center justify-center w-full h-full">
            <!-- Temperature, Icon, Condition -->
            <div class="flex flex-col items-center mb-2">
              <div class="text-5xl font-bold">
                {round(@weather.temperature)}°F
              </div>

              <img
                src={"https://openweathermap.org/img/wn/#{@weather.icon_code}@2x.png"}
                alt="Weather Icon"
                class="w-16 h-16 my-2"
              />

              <div class="text-center capitalize text-sm">
                {format_condition(@weather.condition)}
              </div>
            </div>

    <!-- Centered Weather Stats -->
            <div class="flex flex-col items-center gap-2 mt-2">
              <div class="flex items-center gap-2">
                <span class="text-xl">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    fill="currentColor"
                    class="bi bi-wind"
                    viewBox="0 0 16 16"
                  >
                    <path d="M12.5 2A2.5 2.5 0 0 0 10 4.5a.5.5 0 0 1-1 0A3.5 3.5 0 1 1 12.5 8H.5a.5.5 0 0 1 0-1h12a2.5 2.5 0 0 0 0-5m-7 1a1 1 0 0 0-1 1 .5.5 0 0 1-1 0 2 2 0 1 1 2 2h-5a.5.5 0 0 1 0-1h5a1 1 0 0 0 0-2M0 9.5A.5.5 0 0 1 .5 9h10.042a3 3 0 1 1-3 3 .5.5 0 0 1 1 0 2 2 0 1 0 2-2H.5a.5.5 0 0 1-.5-.5" />
                  </svg>
                </span>
                <span class="text-sm">{round(@weather.wind_speed)} mph</span>
              </div>
              <div class="flex items-center gap-2">
                <span class="text-xl">💧</span>
                <span class="text-sm">{@weather.humidity}%</span>
              </div>
              <div class="flex items-center gap-2">
                <span class="text-xl">🌡️</span>
                <span class="text-sm">{@weather.pressure} mmHg</span>
              </div>
            </div>
          </div>
        <% end %>
      </.card>
    </div>
    """
  end

  defp format_weather(%{
         "main" => %{"temp" => temp, "humidity" => humidity, "pressure" => pressure},
         "weather" => [%{"description" => description, "icon" => icon}],
         "wind" => %{"speed" => wind_speed},
         "name" => location
       }) do
    %{
      temperature: temp,
      condition: description,
      wind_speed: wind_speed,
      location: location,
      humidity: humidity,
      pressure: convert_pressure_to_mmhg(pressure),
      icon_code: icon
    }
  end

  defp format_condition(condition) do
    condition
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp convert_pressure_to_mmhg(hpa) do
    Float.round(hpa * 0.75006, 1)
  end
end
