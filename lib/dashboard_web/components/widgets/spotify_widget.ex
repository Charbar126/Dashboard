defmodule DashboardWeb.Components.Widgets.SpotifyWidget do
  require Logger
  alias DashboardWeb.SpotifyController
  alias Dashboard.Api.SpotifyApi
  use Phoenix.LiveComponent
  import DashboardWeb.Ui.Card
  import DashboardWeb.CoreComponents

  def mount(socket) do
    case SpotifyController.refresh_spotify_token() do
      {:ok, access_token} ->
        socket =
          socket
          |> assign(:spotify_access_token, access_token)
          |> assign(:player, nil)
          |> assign(:profile, nil)

        {:ok, socket}

      {:error, reason} ->
        {:ok, assign(socket, :spotify_error, "Could not refresh token: #{inspect(reason)}")}
    end
  end

  @doc """
    Have to use a fucking hidden button to get the player :(
  """
  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <div id="spotify-player" phx-hook="SpotifyPoller" data-token={@spotify_access_token}>
          <button id="get_profile" phx-click="get_profile" phx-target={@myself}>
            Get Profile
          </button>
          <button
            id="hidden_get_player"
            phx-click="get_player"
            phx-target={@myself}
            style="display: none;"
          >
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

  def handle_event("get_profile", _params, socket) do
    case socket.assigns[:spotify_access_token] do
      nil ->
        {:noreply, put_flash(socket, :error, "No Spotify token found. Please authorize.")}

      access_token ->
        case SpotifyController.get_profile(access_token) do
          {:ok, profile} ->
            {:noreply, assign(socket, :profile, profile)}

          {:error, reason} ->
            {:noreply, put_flash(socket, :error, "Failed to fetch Spotify state: #{reason}")}
        end
    end
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
            {:noreply, put_flash(socket, :info, "Player stopped.")}

          {:ok, _response} ->
            refresh_player(socket)
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
            refresh_player(socket)
            {:noreply, put_flash(socket, :info, "Player resumed.")}

          {:ok, _response} ->
            refresh_player(socket)
            {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

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

          # {:noreply, put_flash(socket, :info, "Track skipped.")}

          {:ok, _response} ->
            refresh_player(socket)

          # {:noreply, put_flash(socket, :info, "Unexpected response from Spotify.")}

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

  defp get_album_image_url(player) do
    get_in(player, ["item", "album", "images"])
    |> List.first()
    |> Map.get("url")
  end

  defp get_playback_state(player) do
    get_in(player, ["is_playing"])
  end

  # def handle_event("refresh_spotify_token", _params, socket) do
  #   case SpotifyController.refresh_access_token() do
  #     {:ok, %{access_token: access_token}} ->
  #       {:noreply, assign(socket, :spotify_access_token, access_token)}

  #     {:error, reason} ->
  #       Logger.error("Failed to refresh Spotify token: #{inspect(reason)}")
  #       {:noreply, socket |> assign(:spotify_error, "Could not refresh token")}
  #   end
  # end
end
