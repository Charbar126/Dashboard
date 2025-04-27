defmodule DashboardWeb.Live.DashboardLive do
  use Phoenix.LiveView
  alias DashboardWeb.Components.Widgets
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
    <div class="min-h-screen flex flex-col items-center bg-gray-50">

      <!-- Top Padding Spacer -->
      <div class="h-8"></div>

      <!-- Main Content Grid -->
      <div class="w-full max-w-7xl grid grid-cols-1 md:grid-cols-6 gap-4 p-4">

        <!-- LEFT SIDE (Main Personal Widgets) -->
        <div class="md:col-span-4 space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <%= if @google_access_token != nil do %>
              <.live_component
                module={Widgets.GmailWidget}
                id="gmail-widget"
                google_access_token={@google_access_token}
              />
              <.live_component
                module={Widgets.GoogleCalendarWidget}
                id="google-calendar-widget"
                google_access_token={@google_access_token}
              />
            <% else %>
              <.live_component
                module={Widgets.GoogleAuthetnicationWidget}
                id="google-authentication-widget"
              />
            <% end %>

            <.live_component module={Widgets.WeatherWidget} id="weather-widget" />

            <%= if @spotify_access_token != nil do %>
              <.live_component
                module={Widgets.SpotifyWidget}
                id="spotify-widget"
                spotify_access_token={@spotify_access_token}
              />
            <% else %>
              <.live_component
                module={Widgets.SpotifyAuthenticaionWidget}
                id="spotify-auth-widget"
              />
            <% end %>

            <.live_component
              module={Widgets.DictionaryWidget}
              id="dictionary-widget"
            />
          </div>
        </div>

        <!-- RIGHT SIDE (Top Headlines) -->
        <div class="md:col-span-2 space-y-4">
          <.live_component module={Widgets.NewsWidget} id="news-widget" />
        </div>

      </div>
    </div>
    """
  end

end
