defmodule Dashboard.Api.SpotifyApi do
  @doc """
  Generates a URL for Spotify authorization page
  Query Parameter:
    Cleint ID: Spotify Client ID - Defined in .env
    Response Type: code - Set to code for general access
    Redirect URI: Spotify Redirect URI - Defined in .env
    state: A unique and non-guessable value used to prevent cross-site request forgery attack
  """
  def gen_auth_url() do
    # "&state=#{state}"
    url =
      "https://accounts.spotify.com/authorize" <>
        "?client_id=#{Dotenv.get("SPOTIFY_CLIENT_ID")}" <>
        "&response_type=code" <>
        "&redirect_uri=#{URI.encode(Dotenv.get("SPOTIFY_REDIRECT_URI"))}" <>
        "&scope=#{Dotenv.get("SPOTIFY_SCOPE")}"

    IO.inspect(url)

    url
  end

  @doc """
  Exchanges the authorization code for an access token from spotify
  #NEED to add in error handling
  """
  def exchange_code_for_token(code) do
    auth_string = "#{Dotenv.get("SPOTIFY_CLIENT_ID")}:#{Dotenv.get("SPOTIFY_CLIENT_SECRET")}"
    encoded_auth = Base.encode64(auth_string)

    body =
      URI.encode_query(%{
        code: code,
        redirect_uri: Dotenv.get("SPOTIFY_REDIRECT_URI"),
        grant_type: "authorization_code"
      })

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Authorization", "Basic #{encoded_auth}"}
    ]

    url = Dotenv.get("SPOTIFY_TOKEN_URL")

    HTTPoison.post(url, body, headers)
  end

  @doc """
  Refreshes the access token using the refresh token.
  #NEED to add in error handling
  """
  def refresh_access_token(refresh_token) do
    auth_string = "#{Dotenv.get("SPOTIFY_CLIENT_ID")}:#{Dotenv.get("SPOTIFY_CLIENT_SECRET")}"
    encoded_auth = Base.encode64(auth_string)

    headers = [
      {"Authorization", "Basic #{encoded_auth}"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    payload =
      URI.encode_query(%{
        client_id: "#{Dotenv.get("SPOTIFY_CLIENT_ID")}",
        grant_type: "refresh_token",
        refresh_token: refresh_token
      })

    url = Dotenv.get("SPOTIFY_TOKEN_URL")

    HTTPoison.post(url, payload, headers)
  end

  @doc """
  Fetches the Spotify user's profile to check their account type.
  Requires an access token.
  """
  def get_profile(access_token) do
    url = "https://api.spotify.com/v1/me"

    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers, timeout: 5000, recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        profile = Jason.decode!(body)
        {:ok, profile}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status: status_code, body: body}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Fetches the Spotify player data.
  Requires an access token.
  """
  def get_player(access_token) do
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    url = "https://api.spotify.com/v1/me/player"

    case HTTPoison.get(url, headers, timeout: 5000, recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      # No player found
      {:ok, %HTTPoison.Response{status_code: 204, body: _body}} ->
        {:ok, nil}

      {:error, error} ->
        {:error, error}
    end
  end

  def stop_player(access_token) do
    headers = [
      {"Authorization", "Bearer #{access_token}"}
    ]

    url = "https://api.spotify.com/v1/me/player/pause"

    case HTTPoison.put(url, "", headers, timeout: 5000, recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:ok, "No active device found"}

      {:error, error} ->
        {:error, error}
    end
  end

  def resume_player(access_token) do
    headers = [
      {"Authorization", "Bearer #{access_token}"}
    ]

    url = "https://api.spotify.com/v1/me/player/play"

    case HTTPoison.put(url, "", headers, timeout: 5000, recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:ok, "No active device found"}

      {:error, error} ->
        {:error, error}
    end
  end

  def skip_to_next_player(access_token) do
    headers = [
      {"Authorization", "Bearer #{access_token}"}
    ]

    url = "https://api.spotify.com/v1/me/player/next"

    case HTTPoison.post(url, "", headers, timeout: 5000, recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:ok, "No active device found"}

      {:ok, %HTTPoison.Response{status_code: 405}} ->
        {:ok, "Device Should skiip not sure"}

      {:error, error} ->
        {:error, error}
    end
  end

  def skip_to_previous_player(access_token) do
    headers = [
      {"Authorization", "Bearer #{access_token}"}
    ]

    url = "https://api.spotify.com/v1/me/player/previous"

    case HTTPoison.post(url, "", headers, timeout: 5000, recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:ok, "No active device found"}

      {:error, error} ->
        {:error, error}
    end
  end
end
