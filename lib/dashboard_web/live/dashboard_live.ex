defmodule DashboardWeb.Live.DashboardLive do
  use Phoenix.LiveView
  # Or whatever module handles Google token logic
  alias DashboardWeb.GoogleController
  alias DashboardWeb.SpotifyController

  def mount(_params, _session, socket) do
    socket =
      case GoogleController.refresh_access_token() do
        {:ok, token} ->
          IO.inspect(token, label: "Google Token")
          assign(socket, :google_access_token, token)

        {:error, reason} ->
          IO.inspect(reason, label: "Google Token Error")
          assign(socket, :google_access_token, nil)
      end

    socket =
      case SpotifyController.refresh_spotify_token() do
        {:ok, token} ->
          IO.inspect(token, label: "Spotify Token")
          assign(socket, :spotify_access_token, token)

        {:error, reason} ->
          IO.inspect(reason, label: "Spotify Token Error")
          assign(socket, :spotify_access_token, nil)
      end

    {:ok, socket}
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

      <%!-- Spotify  NOTE: NEED TO PASS IN THE SAME SIZE--%>
      <%!-- <%= if @spotify_access_token != nil do %> --%>
        <.live_component module={DashboardWeb.Components.Widgets.SpotifyWidget} id="spotify-widget" />
      <%!-- <% else %> --%>
        <.live_component
          module={DashboardWeb.Components.Widgets.SpotifyAuthenticaionWidget}
          id="spotify-auth-widget"
        />
      <%!-- <% end %> --%>

      <.live_component module={DashboardWeb.Components.Widgets.NewsWidget} id="news-widget" />
      <.live_component
        module={DashboardWeb.Components.Widgets.DictionaryWidget}
        id="dictionary-widget"
      />
    </div>
    """
  end
end
