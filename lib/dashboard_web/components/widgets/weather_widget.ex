defmodule DashboardWeb.Widgets.WeatherWidget do
  import DashboardWeb.Ui.Card
  use Phoenix.LiveComponent
  alias DashboardWeb.Api.WeatherController

  def update(assigns, socket) do
    send(self(), :fetch_weather)
    {:ok, assign(socket, weather: nil, loading: true)}
  end

  # def handle_info(:fetch_weather, socket) do
  #   weather = fetch_weather_data()
  #   {:noreply, assign(socket, weather: weather, loading: false)}
  # end

  def render(assigns) do
    ~H"""
    <div>
      <.card></.card>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
