defmodule DashboardWeb.Live.DashboardLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div>
      <%!-- <.live_component module={DashboardWeb.Components.Widgets.StockWidget} id="stock-widget" /> --%>
      <.live_component module={DashboardWeb.Components.Widgets.WeatherWidget} id="weather-widget" />
      <.live_component module={DashboardWeb.Components.Widgets.SpotifyWidget} id="spotify-widget" />
      <%!-- <.live_component module={DashboardWeb.Components.Widgets.NewsWidget} id="news-widget" /> --%>
      <.live_component
        module={DashboardWeb.Components.Widgets.DictionaryWidget}
        id="dictionary-widget"
      />
    </div>
    """
  end

  def mount(_params, session, socket) do
    spotify_token = session["spotify_token"]
    {:ok, assign(socket, spotify_token: spotify_token)}
  end
end
