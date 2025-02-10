defmodule DashboardWeb.Components.Widgets.SpotifyWidget do
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
        <div id="spotify-player" phx-hook="SpotifyPlayer" data-token={@spotify_access_token}></div>
        <button id="togglePlay">Toggle Play</button>
      </.card>
    </div>
    """
  end

  def handle_event("authorize", _params, socket) do
    {:noreply, redirect(socket, external: "/auth/spotify")}
  end
end
