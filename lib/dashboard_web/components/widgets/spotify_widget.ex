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
        <button phx-click="authorize">Authorize Spotify</button>
      </.card>
    </div>
    """
  end

  # Look into show dialog
  def handle_event("authorize", _params, socket) do
    authorization_url =
      "#{Dotenv.get("SPOTIFY_AUTHORIZATION_URL")}?
        client_id=#{Dotenv.get("SPOTIFY_CLIENT_ID")}.
        &response_type=code
        &redirect_uri=#{Dotenv.get("SPOTIFY_REDIRECT_URI")}
        &scope=#{Dotenv.get("SPOTIFY_SCOPE")}"

    {:noreply, push_redirect(socket, to: authorization_url)}
  end

  def mount(socket) do
    {:ok, socket}
  end
end
