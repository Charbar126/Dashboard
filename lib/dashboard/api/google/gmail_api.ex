defmodule Dashboard.Api.Google.GmailApi do
  @moduledoc """
  Provides functions to fetch Gmail metadata such as unread email count.
  """

  def fetch_unread_emails(access_token) do
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]
    url = "https://gmail.googleapis.com/gmail/v1/users/me/labels/INBOX"
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> Map.get("messagesUnread", 0)
        |> then(&{:ok, &1})

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, %{status: code, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
