defmodule DashboardWeb.Components.Widgets.SpotifyWidget do
  import DashboardWeb.Ui.SpotifyPlayer
  import DashboardWeb.Ui.Card
  use Phoenix.LiveComponent
  alias Dashboard.Api.SpotifyApi, as: SpotifyApi

  def update(_assigns, socket) do
    {:ok, socket}
  end

  # Need to add a state in call... Will add in finishing touches... Protects against attacks
  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <button phx-click="authorize" phx-target={@myself}>Authorize Spotify</button>
      </.card>
    </div>
    """
  end

  # Look into show dialog
  def handle_event("authorize", _params, socket) do
    spotify_auth_url = SpotifyApi.authorize_url()
    {:noreply, redirect(socket, external: spotify_auth_url)}
  end

  def mount(socket) do
    {:ok, socket}
  end
end
