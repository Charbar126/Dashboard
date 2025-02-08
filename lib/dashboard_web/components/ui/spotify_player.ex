defmodule DashboardWeb.Ui.SpotifyPlayer do
  import DashboardWeb.Ui.Card
  use Phoenix.Component


# Need to 
  def spotify_player(assigns) do
    ~H"""
    <div>
      <.card>
        <p>You need to log in to Spotify to access your music.</p>
        <button phx-click="login_with_spotify">Login with Spotify</button>
      </.card>
    </div>
    """
  end

end
