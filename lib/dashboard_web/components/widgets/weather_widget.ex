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
      <.card class="bg-white text-black p-6 rounded-lg shadow-md">
        <%= if @weather[:error] do %>
          <p class="text-red-500">Error: <%= @weather[:error] %></p>
        <% else %>
          <!-- Location on top -->
          <div class="text-center text-xl font-bold mb-4">
            <%= @weather.location %>
          </div>

          <!-- Main weather data -->
          <div class="flex items-center justify-center gap-6">
            <!-- Temperature, Icon, Condition -->
            <div class="flex flex-col items-center">
              <div class="text-5xl font-bold">
                <%= round(@weather.temperature) %>°F
              </div>

              <img
                src={"https://openweathermap.org/img/wn/#{@weather.icon_code}@2x.png"}
                alt="Weather Icon"
                class="w-16 h-16 my-2"
              />

              <div class="text-center capitalize text-md">
                <%= format_condition(@weather.condition) %>
              </div>
            </div>

            <!-- Other Weather Stats -->
            <div class="flex flex-col justify-center text-sm gap-2">
              <div class="flex items-center gap-2">
                🌬️ <span><%= round(@weather.wind_speed) %> mph</span>
              </div>
              <div class="flex items-center gap-2">
                💧 <span><%= @weather.humidity %>%</span>
              </div>
              <div class="flex items-center gap-2">
                🌡️ <span><%= @weather.pressure %> mmHg</span>
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
