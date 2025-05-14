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
    <div class="h-full w-full">
      <.card height="h-full" width="w-full" padding="p-4" background="bg-white dark:bg-zinc-800">
        <div
          id="spotify-player"
          phx-hook="SpotifyPoller"
          data-token={@spotify_access_token}
          class="flex flex-col justify-between items-center w-full h-full"
        >
          <button
            id="hidden_get_player"
            phx-click="get_player"
            phx-target={@myself}
            style="display: none;"
          >
          </button>

          <%= if @player do %>
            <div class="flex flex-col items-center w-full h-full justify-between">
              <div class="album-art mb-2">
                <img
                  src={get_album_image_url(@player)}
                  alt="album-cover"
                  class="w-32 h-32 shadow-md object-cover rounded-lg"
                />
              </div>

    <!-- Now Playing Info -->
              <div class="text-center mb-2 w-full px-2">
                <div class="relative overflow-hidden whitespace-nowrap w-full">
                  <div class={
                "inline-block font-semibold text-sm transition-all " <>
                (if String.length(get_track_name(@player)) > 20, do: "animate-marquee", else: "")
              }>
                    {get_track_name(@player)}
                  </div>
                </div>
                <p class="text-[10px] text-gray-400 truncate">{get_album_name(@player)}</p>
                <p class="text-xs text-gray-500 truncate">{get_artist_name(@player)}</p>
              </div>

    <!-- Player Controls -->
              <div class="player-controls mt-2">
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
            </div>
          <% else %>
            <div class="flex flex-col items-center justify-center space-y-2">
              <.icon name="hero-musical-note" class="w-16 h-16 opacity-60" />
              <p class="text-center text-sm">No Spotify player found</p>
              <p class="text-center text-xs text-gray-400">Open Spotify and play a song!</p>
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
            refresh_player(socket)

          {:ok, _response} ->
            {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

          {:error, error} ->
            Logger.error("Error fetching Spotify player: #{inspect(error)}")
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify player.")}
        end
    end
  end


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


  defp get_track_name(player) do
    get_in(player, ["item", "name"]) || "Unknown Track"
  end

  defp get_artist_name(player) do
    case get_in(player, ["item", "artists"]) do
      [%{"name" => name} | _] -> name
      _ -> "Unknown Artist"
    end
  end

  defp get_album_image_url(player) do
    get_in(player, ["item", "album", "images"])
    |> List.first()
    |> Map.get("url")
  end

  defp get_album_name(player) do
    get_in(player, ["item", "album", "name"]) || "Unknown Album"
  end

  defp get_playback_state(player) do
    get_in(player, ["is_playing"])
  end
end
