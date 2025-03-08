defmodule DashboardWeb.Components.Widgets.SpotifyWidget do
  require Logger
  alias Dashboard.Api.SpotifyApi
  use Phoenix.LiveComponent
  import DashboardWeb.Ui.Card

  def update(_assigns, socket) do
    case Dashboard.SpotifyTokens.get_latest_spotify_token() do
      %Dashboard.SpotifyTokens.SpotifyToken{access_token: access_token} ->
        {:ok, assign(socket, spotify_access_token: access_token)}

      nil ->
        {:ok, assign(socket, spotify_access_token: nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <button phx-click="authorize" phx-target={@myself}>Authorize Spotify</button>
        <!-- The container below is still hooked so that the client can push events -->
        <div id="spotify-player" phx-hook="SpotifyPlayer" data-token={@spotify_access_token}>
          <button id="get_profile" phx-click="get_profile" phx-target={@myself}>
            Get Current State
          </button>
          <button id="get_player" phx-click="get_player" phx-target={@myself}>
            Get Player State
          </button>
        </div>
      </.card>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("authorize", _params, socket) do
    {:noreply, redirect(socket, external: "/auth/spotify")}
  end

  def handle_event("get_profile", _params, socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyApi.get_profile(access_token) do
          {:ok, profile} ->
            {:noreply, assign(socket, :profile, profile)}

          {:error, reason} ->
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify state: #{reason}")}
        end
    end
  end

  def handle_event("get_player", _params, socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyApi.get_player(access_token) do
          {:ok, nil} ->
            Logger.info("No Spotify player found.")
            {:noreply, put_flash(socket, :error, "No Spotify player found.")}

          {:ok, player} ->
            Logger.info(" Spotify player found.")
            IO.inspect(player, label: "Spotify Player")
            {:noreply, assign(socket, :player, player)}

          {:error, reason} ->
            Logger.info(" Error Spotify Player.")
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify player: #{reason}")}
        end
    end
  end

  # def handle_event("toggle_play", _params, socket) do
  #   case socket.assigns[:spotify_access_token] do
  #     nil ->
  #       {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

  #     access_token ->
  #       SpotifyApi.get_profile(access_token)
  #       {:noreply, socket}
  #   end
  # end
end
