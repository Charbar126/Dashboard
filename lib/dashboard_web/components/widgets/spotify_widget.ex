defmodule DashboardWeb.Components.Widgets.SpotifyWidget do
  alias DashboardWeb.SpotifyController, as: SpotifyController
  alias Dashboard.Api.SpotifyApi, as: SpotifyApi
  import DashboardWeb.Ui.Card
  use Phoenix.LiveComponent

  def update(_assigns, socket) do
    case Dashboard.SpotifyTokens.get_latest_spotify_token() do
      %Dashboard.SpotifyTokens.SpotifyToken{
        access_token: access_token,
        refresh_token: refresh_token
      } = token ->
        IO.inspect(token)

        {:ok,
         assign(socket, spotify_access_token: access_token, spotify_refresh_token: refresh_token)}

      nil ->
        {:ok, assign(socket, spotify_access_token: nil, spotify_refresh_token: nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <button phx-click="authorize" phx-target={@myself}>Authorize Spotify</button>
        <p>Access Token: {@spotify_access_token || "No token available"}</p>
        <p>Refresh Token: {@spotify_refresh_token || "No token available"}</p>
      </.card>
    </div>
    """
  end

  def handle_event("authorize", _params, socket) do
    {:noreply, redirect(socket, external: "/auth/spotify")}
  end

  def mount(socket) do
    {:ok, socket}
  end
end
