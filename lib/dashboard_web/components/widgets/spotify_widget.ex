defmodule DashboardWeb.Components.Widgets.SpotifyWidget do
  require Logger
  alias DashboardWeb.SpotifyController
  alias Dashboard.Api.SpotifyApi
  alias Dashboard.SpotifyTokens
  use Phoenix.LiveComponent
  import Phoenix.LiveComponent
  import DashboardWeb.Ui.Card
  import DashboardWeb.CoreComponents

  # Check for profile
  # Get device id and pass it to the player functions
  # This is apparently never called
  def mount(socket) do
    IO.inspect("Mounting Spotify Widget")

    {:ok,
     assign(socket, %{spotify_access_token: nil, player: nil, profile: nil, is_playing: nil})}
  end

  # {:ok,
  #  assign(socket, %{spotify_access_token: spotify_access_token, player: nil, is_playing: nil})}

  def update(_assigns, socket) do
    case SpotifyTokens.get_latest_spotify_token() do
      %SpotifyTokens.SpotifyToken{access_token: access_token} ->
        {:ok, assign(socket, spotify_access_token: access_token)}

      nil ->
        {:ok, assign(socket, spotify_access_token: nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <%!-- <%= if assigns.spotify_access_token == nil do %> --%>
        <button phx-click="authroize_spotify" phx-target={@myself}>Authorize Spotify</button>
        <button phx-click="refresh_spotify_token" phx-target={@myself}>Refresh Spotify</button>
        <%!-- <% else %> --%>
        <div id="spotify-player" phx-hook="SpotifyPlayer" data-token={@spotify_access_token}>
          <button id="get_profile" phx-click="get_profile" phx-target={@myself}>
            Get Profile
          </button>
          <button id="get_player" phx-click="get_player" phx-target={@myself}>
            Get Player
          </button>
          <%= if assigns.player != nil do %>
            <button
              id="player_skip_to_previous"
              phx-click="player_skip_to_previous"
              phx-target={@myself}
            >
              <.icon name="hero-backward" />
            </button>
            <%= if get_playback_state(@player) do %>
              <button id="stop_player" phx-click="stop_player" phx-target={@myself}>
                <.icon name="hero-pause-circle" />
              </button>
            <% else %>
              <button id="start_player" phx-click="resume_player" phx-target={@myself}>
                <.icon name="hero-play-circle" />
              </button>
            <% end %>
            <button id="player_skip_to_next" phx-click="player_skip_to_next" phx-target={@myself}>
              <.icon name="hero-forward" />
            </button>
            <%!-- Need to get player on successful mount --%>
            <img src={get_album_image_url(@player)} alt="Album cover" width="300" height="300" />
          <% end %>
        </div>
        <%!-- <% end %> --%>
      </.card>
    </div>
    """
  end

  def handle_event("authroize_spotify", _params, socket) do
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

  def handle_event("refresh_spotify_token", _params, socket) do
    SpotifyController.refresh_access_token()
    {:noreply, socket}
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
