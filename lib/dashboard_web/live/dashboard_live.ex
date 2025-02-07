defmodule DashboardWeb.Live.DashboardLive do
  use Phoenix.LiveView
  import DashboardWeb.Widgets.WeatherWidget

  def render(assigns) do
    ~H"""
    <div>
      <.live_component module={DashboardWeb.Widgets.WeatherWidget} id="weather-widget" />
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
