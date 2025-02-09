defmodule DashboardWeb.Components.Widgets.SpotifyWidget do
  alias DashboardWeb.SpotifyController, as: SpotifyController
  alias Dashboard.Api.SpotifyApi, as: SpotifyApi
  import DashboardWeb.Ui.Card
  use Phoenix.LiveComponent

  def update(_assigns, socket) do
    IO.inspect(Dashboard.SpotifyTokens.get_latest_spotify_token())
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
    # Becuase both the controller and liveview are in the backend you have to redirect
    {:noreply, redirect(socket, external: "/auth/spotify")}
  end

  def mount(socket) do
    {:ok, socket}
  end
end
