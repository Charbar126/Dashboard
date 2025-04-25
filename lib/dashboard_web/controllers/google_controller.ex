defmodule DashboardWeb.GoogleController do
  use DashboardWeb, :controller
  alias Dashboard.Api.Google.GoogleAuthAPI
  alias Dashboard.Api.Google.GoogleCalendarApi
  alias Dashboard.Api.Google.GmailApi
  alias Dashboard.GoogleTokens

  def authenticate_user(conn, _params) do
    # Redirect to the Google authorization URL
    url = GoogleAuthAPI.gen_auth_url()

    conn |> redirect(external: url)
  end

  def callback_user_auth(conn, %{"code" => code}) do
    case GoogleAuthAPI.exchange_code_for_token(code) do
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

  @doc """
  Refreshes the Google access token using the refresh token.
  """
  def refresh_access_token() do
    refresh_token = get_recent_google_token().refresh_token

    case GoogleAuthAPI.refresh_access_token(refresh_token) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        token_data = Jason.decode!(body)
        formatted_data = format_token_data(token_data)
        {:ok, formatted_data.access_token}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        IO.inspect({status, body}, label: "Error response from Google")
        {:error, %{status: status, body: body}}

      {:error, reason} ->
        IO.inspect(reason, label: "HTTP request error")
        {:error, reason}
    end
  end

  def get_recent_google_token do
    Dashboard.GoogleTokens.get_latest_google_token()
  end



  # MAKE THIS DONE BY WEEK SO I CAN GET THE WEEK AND DISPLAY THE CURRENT DAY
  def get_google_calendar(access_code) do
    case GoogleCalendarApi.fetch_today_events(access_code) do
      {:ok, calendar_events} -> {:ok, calendar_events}
      {:error, reason} ->
        IO.inspect(reason, label: "Failed to fetch Google Calendar events")
        {:error, reason}
    end
  end

  # MIGHT NEED A BETTER NAME
  def get_unread_emails(access_token) do
    case GmailApi.fetch_unread_emails(access_token) do
      {:ok, number_of_emails} ->
        {:ok, number_of_emails}

      {:error, reason} ->
        IO.inspect(reason, label: "Failed to fetch number of unread emails")
        {:error, reason}
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
