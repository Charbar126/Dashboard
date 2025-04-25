defmodule DashboardWeb.Components.Widgets.GmailWidget do
  use Phoenix.LiveComponent
  import DashboardWeb.Ui.Card
  alias DashboardWeb.GoogleController

  def update(%{google_access_token: access_token}, socket) do
    case GoogleController.get_unread_emails(access_token) do
      {:ok, count} ->
        {:ok, assign(socket, unread_email_count: count)}

      {:error, reason} ->
        IO.inspect(reason, label: "Failed to fetch number of unread emails")
        {:ok, assign(socket, unread_email_count: 0)}
    end
  end

  def render(assigns) do
    ~H"""
    <.card>
      <h3 class="text-xl font-bold">Gmail</h3>
      <p class="text-gray-700 mt-2">
        You have <strong><%= @unread_email_count %></strong> unread email<%= if @unread_email_count != 1, do: "s", else: "" %>.
      </p>
      <a
        href="https://mail.google.com/mail/u/0/#search/is%3Aunread"
        class="inline-block mt-3 text-blue-600 hover:underline"
        target="_blank"
        rel="noopener noreferrer"
      >
        View Unread Emails in Gmail →
      </a>
    </.card>
    """
  end
end
