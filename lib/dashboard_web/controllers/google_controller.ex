defmodule DashboardWeb.GoogleController do
  use DashboardWeb, :controller
  alias Dashboard.Api.GoogleApi
  alias Dashboard.GoogleTokens

  def authenticate_user(conn, _params) do
    # Redirect to the Google authorization URL
    url = GoogleApi.gen_auth_url()

    conn |> redirect(external: url)
    # NEED TO MAKE THIS A REGULAR FUNCTIN
  end

  def callback_user_auth(conn, %{"code" => code}) do
    # Exchange the authorization code for an access token
    case GoogleApi.exchange_code_for_token(code) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        token_data = Jason.decode!(body)
        formatted_data = format_token_data(token_data)

        GoogleTokens.create_google_token(formatted_data)

        conn |> redirect(to: "/")

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        IO.inspect({status, body}, label: "Error response from Google")
        conn |> redirect(to: "/error")

      {:error, reason} ->
        IO.inspect(reason, label: "HTTP request error")
        conn |> redirect(to: "/error")
    end
  end

  defp format_token_data(token_data) do
    %{
      access_token: token_data["access_token"],
      refresh_token: token_data["refresh_token"],
      expires_at: DateTime.utc_now() |> DateTime.add(token_data["expires_in"], :second)
    }
  end

  
end
