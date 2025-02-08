defmodule DashboardWeb.SpotifyController do
  use DashboardWeb, :controller
  alias Dashboard.Api.SpotifyApi
  alias Dashboard.Repo
  alias Dashboard.SpotifyToken
  alias DashboardWeb.Router.Helpers, as: Routes

  def callback(conn, %{"code" => code, "state" => state}) do
    # Validate state for CSRF protection
    if valid_state?(state) do
      case SpotifyApi.exchange_code_for_token(code) do
        {:ok,
         %{
           "access_token" => access_token,
           "refresh_token" => refresh_token,
           "expires_in" => expires_in
         }} ->
          # Store the tokens in your database
          store_tokens(access_token, refresh_token, expires_in)

          # Redirect back to the dashboard after successful authorization
          conn
          |> redirect(to: Routes.live_path(conn, DashboardWeb.Live.DashboardLive))

        {:error, reason} ->
          Logger.error("Spotify authorization failed: #{inspect(reason)}")

          conn
          |> put_flash(:error, "Authorization failed. Please try again.")
          |> redirect(to: "/")
      end
    else
      # If the state doesn't match, reject the request
      conn
      |> put_flash(:error, "Invalid request.")
      |> redirect(to: "/")
    end
  end

  defp valid_state?(state) do
    # Validate the state (this can be a custom implementation to prevent CSRF)
    state == "expected_state"
  end

  defp store_tokens(access_token, refresh_token, expires_in) do
    %Dashboard.Schema.SpotifyToken{
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: DateTime.utc_now() |> DateTime.add(expires_in, :second)
    }
    |> Repo.insert!()
  end
end
