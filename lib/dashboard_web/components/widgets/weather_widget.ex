defmodule DashboardWeb.Widgets.WeatherWidget do
  import DashboardWeb.Ui.Card
  use Phoenix.LiveComponent
  alias Dashboard.Api.WeatherApi, as: WeatherAPI

  def update(assigns, socket) do
    # Fetch weather data from the API
    case WeatherAPI.get_current_weather() do
      {:ok, raw_data} ->
        formatted_data = format_current_weather(raw_data)
        {:ok, assign(socket, weather: formatted_data)}

      {:error, _reason} ->
        {:ok, assign(socket, weather: %{error: "Failed to fetch weather data"})}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <%= if @weather[:error] do %>
          <p>Error: {@weather[:error]}</p>
        <% else %>
          <p>Temperature: {@weather[:temperature]}°C</p>
          <p>Condition: {@weather[:condition]}</p>
          <p>Wind: {@weather[:wind_speed]}</p>
          <p>Location: {@weather[:location]}</p>
        <% end %>
      </.card>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  defp format_current_weather(%{
         "main" => %{"temp" => temp},
         "weather" => weather,
         "wind" => %{"speed" => wind_speed},
         "name" => location
       }) do
    %{
      temperature: temp,
      condition: Enum.map(weather, fn w -> w["description"] end) |> Enum.join(", "),
      wind_speed: wind_speed,
      location: location
    }
  end
end
