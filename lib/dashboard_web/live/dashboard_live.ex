defmodule DashboardWeb.Live.DashboardLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div>
      <%!-- <.live_component module={DashboardWeb.Components.Widgets.StockWidget} id="stock-widget" /> --%>
      <.live_component module={DashboardWeb.Components.Widgets.WeatherWidget} id="weather-widget" />
      <%!-- <.live_component module={DashboardWeb.Components.Widgets.NewsWidget} id="news-widget" /> --%>
      
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
