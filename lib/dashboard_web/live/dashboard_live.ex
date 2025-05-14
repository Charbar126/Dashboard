defmodule DashboardWeb.Live.DashboardLive do
  import DashboardWeb.Ui.SearchBox
  use Phoenix.LiveView
  alias DashboardWeb.Components.Widgets
  alias DashboardWeb.GoogleController
  alias DashboardWeb.SpotifyController

  def mount(_params, _session, socket) do
    socket =
      case GoogleController.refresh_access_token() do
        {:ok, token} ->
          assign(socket, :google_access_token, token)

        {:error, reason} ->
          IO.inspect(reason, label: "Google Token Error")
          assign(socket, :google_access_token, nil)
      end

    socket =
      case SpotifyController.refresh_spotify_token() do
        {:ok, token} ->
          assign(socket, :spotify_access_token, token)

        {:error, reason} ->
          IO.inspect(reason, label: "Spotify Token Error")
          assign(socket, :spotify_access_token, nil)
      end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
<div class="grid grid-cols-12 gap-4 p-4 h-[calc(100vh-40px)] overflow-hidden">
      <!-- Top search row -->
      <div class="col-start-4 col-span-6 flex items-center justify-center">
        <.search_box />
      </div>
      <div class="col-start-11 col-span-2 flex items-center justify-end">
        <%= if @google_access_token != nil do %>
          <.live_component
            module={Widgets.GmailWidget}
            id="gmail-widget"
            google_access_token={@google_access_token}
          />
        <% end %>
      </div>
      
    <!-- Left column -->
      <div class="col-start-1 col-span-4 h-full flex flex-col space-y-4 overflow-hidden">
        <.live_component module={Widgets.DictionaryWidget} id="dictionary-widget" />
        <div class="grid grid-cols-2 gap-4 flex-grow min-h-0">
          <div class="h-full">
            <%= if @spotify_access_token do %>
              <.live_component
                module={Widgets.SpotifyWidget}
                id="spotify-widget"
                spotify_access_token={@spotify_access_token}
              />
            <% else %>
              <.live_component module={Widgets.SpotifyAuthenticaionWidget} id="spotify-auth-widget" />
            <% end %>
          </div>
          <div class="h-full">
            <.live_component module={Widgets.WeatherWidget} id="weather-widget" />
          </div>
        </div>
      </div>
      
    <!-- Middle column -->
      <div class="col-start-5 col-span-4 h-full flex flex-col">
        <%= if @google_access_token do %>
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
      </div>
      
    <!-- Right column -->
      <div class="col-start-9 col-span-4 h-full flex flex-col overflow-hidden">
        <.live_component module={Widgets.NewsWidget} id="news-widget" />
      </div>
    </div>
    """
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, socket}
  end
end
