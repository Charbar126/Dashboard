defmodule DashboardWeb.Components.Widgets.GmailWidget do
  use Phoenix.LiveComponent
  alias DashboardWeb.GoogleController

  # Normal case: we have a token
  def update(%{google_access_token: access_token}, socket) do
    case GoogleController.get_unread_emails(access_token) do
      {:ok, count} ->
        {:ok, assign(socket, unread_email_count: count)}

      {:error, reason} ->
        IO.inspect(reason, label: "Failed to fetch number of unread emails")
        {:ok, assign(socket, unread_email_count: 0)}
    end
  end

  # Fallback: no token yet
  def update(_assigns, socket) do
    {:ok, assign(socket, unread_email_count: 0)}
  end

  def render(assigns) do
    ~H"""
    <a
      href="https://mail.google.com/mail/u/0"
      class="inline-block"
      target="_blank"
      rel="noopener noreferrer"
    >
      <div class="relative w-20 h-20 flex items-center justify-center group hover:scale-110 transition-transform duration-300 cursor-pointer">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="52 42 88 66"
          class="w-full h-full transition-opacity duration-300 opacity-80 group-hover:opacity-100"
        >
          <path fill="#4285f4" d="M58 108h14V74L52 59v43c0 3.32 2.69 6 6 6" />
          <path fill="#34a853" d="M120 108h14c3.32 0 6-2.69 6-6V59l-20 15" />
          <path fill="#fbbc04" d="M120 48v26l20-15v-8c0-7.42-8.47-11.65-14.4-7.2" />
          <path fill="#ea4335" d="M72 74V48l24 18 24-18v26L96 92" />
          <path fill="#c5221f" d="M52 51v8l20 15V48l-5.6-4.2c-5.94-4.45-14.4-.22-14.4 7.2" />
        </svg>

        <!-- Notification Bubble -->
        <div class="absolute -bottom-1 -right-1 bg-sky-500 text-white text-[10px] font-bold rounded-full min-w-[1.75rem] h-5 px-1 flex items-center justify-center shadow leading-none">
          <%= @unread_email_count %>
        </div>
      </div>
    </a>
    """
  end


  # def render(assigns) do
  #   ~H"""
  #   <div>
  #   <.card>

  #     <h3 class="text-xl font-bold">Gmail</h3>
  #     <p class="text-gray-700 mt-2">
  #       You have <strong><%= @unread_email_count %></strong> unread email<%= if @unread_email_count != 1, do: "s", else: "" %>.
  #     </p>
  #     <a
  #       href="https://mail.google.com/mail/u/0/#search/is%3Aunread"
  #       class="inline-block mt-3 text-blue-600 hover:underline"
  #       target="_blank"
  #       rel="noopener noreferrer"
  #     >
  #       View Unread Emails in Gmail →
  #     </a>
  #   </.card>
  #   </div>
  #   """
  # end
end
