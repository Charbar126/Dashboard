defmodule DashboardWeb.Components.Widgets.SpotifyWidget do
  require Logger
  alias DashboardWeb.SpotifyController
  alias Dashboard.Api.SpotifyApi
  use Phoenix.LiveComponent
  import DashboardWeb.Ui.Card
  import DashboardWeb.CoreComponents

  def update(assigns, socket) do
    socket = assign(socket, assigns)

    socket =
      if socket.assigns[:profile] == nil do
        profile = SpotifyController.get_profile(socket.assigns[:spotify_access_token])
        assign(socket, :profile, profile)
      else
        socket
      end

    socket =
      assign_new(socket, :player, fn -> nil end)

    {:ok, socket}
  end

  @doc """
    Have to use a fucking hidden button to get the player :(
  """
  def render(assigns) do
    ~H"""
    <div class="spotify-player-container">
      <.card>
        <div id="spotify-player" phx-hook="SpotifyPoller" data-token={@spotify_access_token}>
          <button
            id="hidden_get_player"
            phx-click="get_player"
            phx-target={@myself}
            style="display: none;"
          >
          </button>

          <%= if assigns.player != nil do %>
            <div class="album-art">
              <img src={get_album_image_url(@player)} alt="album-cover" width="300" height="300" />
            </div>
            <div class="player-controls">
              <button
                id="player_skip_to_previous"
                phx-click="player_skip_to_previous"
                phx-target={@myself}
              >
                <.icon name="hero-backward" class="player-icon" />
              </button>

              <%= if get_playback_state(@player) do %>
                <button id="stop_player" phx-click="stop_player" phx-target={@myself}>
                  <.icon name="hero-pause-circle" class="player-icon" />
                </button>
              <% else %>
                <button id="start_player" phx-click="resume_player" phx-target={@myself}>
                  <.icon name="hero-play-circle" class="player-icon" />
                </button>
              <% end %>

              <button id="player_skip_to_next" phx-click="player_skip_to_next" phx-target={@myself}>
                <.icon name="hero-forward" class="player-icon" />
              </button>
            </div>
          <% end %>
        </div>
      </.card>
    </div>
    """
  end

  def handle_event("get_player", _params, socket) do
    refresh_player(socket)
  end

  def handle_event("stop_player", _params, socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyApi.stop_player(access_token) do
          {:ok} ->
            refresh_player(socket)

          # {:noreply, put_flash(socket, :info, "Player stopped.")}

          {:ok, _response} ->
            refresh_player(socket)

          # {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

          {:error, error} ->
            Logger.error("Error fetching Spotify player: #{inspect(error)}")
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify player.")}
        end
    end
  end

  def handle_event("resume_player", _params, socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyApi.resume_player(access_token) do
          {:ok} ->
            refresh_player(socket)

          # {:noreply, put_flash(socket, :info, "Player resumed.")}

          {:ok, _response} ->
            refresh_player(socket)

          # {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

          {:error, error} ->
            Logger.error("Error fetching Spotify player: #{inspect(error)}")
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify player.")}
        end
    end
  end

  # need to remove the case were there is no token since it will allways exist
  def handle_event("player_skip_to_next", _params, socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyApi.skip_to_next_player(access_token) do
          {:ok} ->
            refresh_player(socket)

          {:ok, _response} ->
            refresh_player(socket)

          {:error, error} ->
            Logger.error("Error fetching Spotify player: #{inspect(error)}")
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify player.")}
        end
    end
  end

  def handle_event("player_skip_to_previous", _params, socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyApi.skip_to_previous_player(access_token) do
          {:ok} ->
              refresh_player(access_token)
          {:ok, _response} ->
            {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

          {:error, error} ->
            Logger.error("Error fetching Spotify player: #{inspect(error)}")
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify player.")}
        end
    end
  end

  @doc """
  This will run after every command in order to make them update the player
  """
  defp refresh_player(socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyApi.get_player(access_token) do
          {:ok, nil} ->
            Logger.info("No active Spotify player found.")
            {:noreply, assign(socket, :player, nil)}

          {:ok, player_data} when is_binary(player_data) ->
            case Jason.decode(player_data) do
              {:ok, player} ->
                Logger.info("Spotify player found.")
                # IO.inspect(player, label: "Spotify Player")
                {:noreply, assign(socket, :player, player)}

              {:error, decode_error} ->
                Logger.error("Failed to decode player data: #{inspect(decode_error)}")
                {:noreply, put_flash(socket, :error, "Error parsing Spotify player data.")}
            end

          {:error, error} ->
            Logger.error("Error fetching Spotify player: #{inspect(error)}")
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify player.")}
        end
    end
  end

  defp get_profile(access_token) do
    SpotifyController.get_profile(access_token)
  end

  defp get_album_image_url(player) do
    get_in(player, ["item", "album", "images"])
    |> List.first()
    |> Map.get("url")
  end

  defp get_playback_state(player) do
    get_in(player, ["is_playing"])
  end
end
