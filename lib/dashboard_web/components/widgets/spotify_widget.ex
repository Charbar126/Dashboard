defmodule DashboardWeb.Components.Widgets.SpotifyWidget do
  require Logger
  alias Dashboard.Api.SpotifyApi
  use Phoenix.LiveComponent
  import DashboardWeb.Ui.Card
  import DashboardWeb.CoreComponents

  # Check for profile
  # Get device id and pass it to the player functions

  def mount(socket) do
    {:ok, assign(socket, %{spotify_access_token: nil, player: nil, is_playing: nil})}
  end

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
            Get Profile
          </button>
          <button id="get_player" phx-click="get_player" phx-target={@myself}>
            Get Player
          </button>
          <button id="stop_player" phx-click="stop_player" phx-target={@myself}>
            Stop
          </button>
          <button id="start_player" phx-click="resume_player" phx-target={@myself}>
            Start
          </button>
          <button id="player_skip_to_next" phx-click="player_skip_to_next" phx-target={@myself}>
            <.icon name="hero-forward" />
          </button>
          <button
            id="player_skip_to_previous"
            phx-click="player_skip_to_previous"
            phx-target={@myself}
          >
          <.icon name="hero-backward" />
          </button>
        </div>
      </.card>
    </div>
    """
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
            Logger.info("No active Spotify player found.")
            {:noreply, assign(socket, :player, nil)}

          {:ok, player_data} when is_binary(player_data) ->
            case Jason.decode(player_data) do
              {:ok, player} ->
                Logger.info("Spotify player found.")
                IO.inspect(player, label: "Spotify Player")
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

  def handle_event("stop_player", _params, socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyApi.stop_player(access_token) do
          {:ok} ->
            {:noreply, put_flash(socket, :info, "Player stopped.")}

          {:ok, _response} ->
            {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

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
            {:noreply, put_flash(socket, :info, "Player resumed.")}

          {:ok, _response} ->
            {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

          {:error, error} ->
            Logger.error("Error fetching Spotify player: #{inspect(error)}")
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify player.")}
        end
    end
  end

  def handle_event("player_skip_to_next", _params, socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyApi.skip_to_next_player(access_token) do
          {:ok} ->
            {:noreply, put_flash(socket, :info, "Track skipped.")}

          {:ok, _response} ->
            {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

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
        case SpotifyApi.skip_to_next_player(access_token) do
          {:ok} ->
            {:noreply, put_flash(socket, :info, "Track skipped.")}

          {:ok, _response} ->
            {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

          {:error, error} ->
            Logger.error("Error fetching Spotify player: #{inspect(error)}")
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify player.")}
        end
    end
  end
end
