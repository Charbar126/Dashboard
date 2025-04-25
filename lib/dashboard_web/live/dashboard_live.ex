defmodule DashboardWeb.Live.DashboardLive do
  use Phoenix.LiveView
  # Or whatever module handles Google token logic
  alias DashboardWeb.GoogleController

  def mount(_params, _session, socket) do
    # should be its own function
    case GoogleController.refresh_access_token() do
      {:ok, token} ->
        IO.inspect(token)
        IO.inspect("Google token refreshed")
        {:ok, assign(socket, :google_access_token, token)}

      {:error, reason} ->
        IO.inspect(reason, label: "Google Token Error")
        {:ok, assign(socket, :google_access_token, nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <%!-- <.live_component module={DashboardWeb.Components.Widgets.StockWidget} id="stock-widget" /> --%>
      <%!-- Need to check if google token is valid --%>
      <.live_component
        module={DashboardWeb.Components.Widgets.GoogleAuthetnicationWidget}
        id="google-authentication-widget"
      />
      <.live_component
        module={DashboardWeb.Components.Widgets.GmailWidget}
        id="gmail-widget"
        google_access_token={@google_access_token}
      />
      <.live_component
        module={DashboardWeb.Components.Widgets.GoogleCalendarWidget}
        id="google-calendar-widget"
        google_access_token={@google_access_token}
      />
      <.live_component module={DashboardWeb.Components.Widgets.WeatherWidget} id="weather-widget" />

      <%!-- <.live_component module={DashboardWeb.Components.Widgets.SpotifyWidget} id="spotify-widget" /> --%>
      <%!-- <.live_component module={DashboardWeb.Components.Widgets.NewsWidget} id="news-widget" /> --%>
      <.live_component
        module={DashboardWeb.Components.Widgets.DictionaryWidget}
        id="dictionary-widget"
      />
    </div>
    """
  end
end
