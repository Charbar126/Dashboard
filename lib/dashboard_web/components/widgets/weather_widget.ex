defmodule DashboardWeb.Components.Widgets.WeatherWidget do
  @moduledoc """
  A LiveComponent that fetches and displays current weather data.

  This widget retrieves weather information from an external API,
  formats the data, and renders it inside a UI card.
  """

  import DashboardWeb.Ui.Card
  use Phoenix.LiveComponent
  alias Dashboard.Api.WeatherApi, as: WeatherAPI

  @doc """
  Updates the LiveComponent state with the latest weather data.

  Fetches weather data from the WeatherAPI module, formats it,
  and assigns it to the socket.

  ## Parameters
    - `_assigns`: Unused assigns (passed by LiveView).
    - `socket`: The LiveView socket.

  ## Returns
    - `{:ok, socket}` with updated weather data or an error message.
  """
  def update(_assigns, socket) do
    case WeatherAPI.get_current_weather() do
      {:ok, raw_data} ->
        formatted_data = format_current_weather(raw_data)
        {:ok, assign(socket, weather: formatted_data)}

      {:error, _reason} ->
        {:ok, assign(socket, weather: %{error: "Failed to fetch weather data"})}
    end
  end

  @doc """
  Renders the weather widget UI.

  Displays the current temperature, weather condition, wind speed, and location.
  If an error occurs, it displays an error message.

  ## Parameters
    - `assigns`: The LiveView assigns containing weather data.

  ## Returns
    - HEEx template for the weather widget.
  """
  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <%= if @weather[:error] do %>
          <p>Error: {@weather[:error]}</p>
        <% else %>
          <p>Temperature: {@weather[:temperature]}°F</p>
          <p>Condition: {@weather[:condition]}</p>
          <p>Wind: {@weather[:wind_speed]}</p>
          <p>Location: {@weather[:location]}</p>
        <% end %>
      </.card>
    </div>
    """
  end

  @doc """
  Initializes the LiveComponent.

  ## Parameters
    - `socket`: The LiveView socket.

  ## Returns
    - `{:ok, socket}` unchanged.
    Need to change this so it actually does something
  """
  def mount(socket) do
    {:ok, socket}
  end

  # Formats raw weather data into a structured map.
  #
  # Extracts temperature, weather conditions, wind speed, and location
  # from the API response.
  #
  # ## Parameters
  #   - `raw_data`: A map containing weather data from the API.
  #
  # ## Returns
  #   - A map with structured weather information:
  #     - `temperature`: Current temperature in °C.
  #     - `condition`: Weather descriptions joined as a string.
  #     - `wind_speed`: Wind speed in the given units.
  #     - `location`: Name of the location.
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
