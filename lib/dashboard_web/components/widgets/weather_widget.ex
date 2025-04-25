defmodule DashboardWeb.Components.Widgets.WeatherWidget do
  @moduledoc """
  A LiveComponent that fetches and displays current weather data.

  This widget retrieves weather information from an external API,
  formats the data, and renders it inside a UI card.
  """

  use Phoenix.LiveComponent
  import DashboardWeb.Ui.Card
  alias Dashboard.Api.WeatherApi, as: WeatherAPI

  @impl true
  def update(_assigns, socket) do
    case WeatherAPI.get_current_weather() do
      {:ok, raw_data} ->
        IO.inspect(raw_data)
        formatted_data = format_current_weather(raw_data)
        {:ok, assign(socket, weather: formatted_data)}

      {:error, _reason} ->
        {:ok, assign(socket, weather: %{error: "Failed to fetch weather data"})}
    end
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <%= if @weather[:error] do %>
          <p>Error: {@weather[:error]}</p>
        <% else %>
          <div id="weather-data" class="grid grid-cols-2">
            <div>
              <img
                src={"https://openweathermap.org/img/wn/#{@weather[:icon_code]}@2x.png"}
                alt="Weather Icon"
              />
            </div>
            <div>
              <p>Location: {@weather[:location]}</p>
              <p>Temperature: {round(@weather[:temperature])}°F</p>
              <p>
                Condition: {@weather[:condition]
                |> String.split()
                |> Enum.map(&String.capitalize/1)
                |> Enum.join(" ")}
              </p>
              <p>Wind: {round(@weather[:wind_speed])} mph</p>
            </div>
          </div>
        <% end %>
      </.card>
    </div>
    """
  end

  # Formats raw weather data into a structured map
  defp format_current_weather(%{
         "main" => %{"temp" => temp},
         "weather" => [first_weather | _],
         "wind" => %{"speed" => wind_speed},
         "name" => location
       }) do
    %{
      temperature: temp,
      condition: first_weather["description"] || "Unknown",
      wind_speed: wind_speed,
      location: location,
      icon_code: first_weather["icon"] || "01d"
    }
  end
end
