defmodule DashboardWeb.Components.Widgets.GoogleAuthetnicationWidget do
  alias Dashboard.Api.GoogleApi
  # alias Dashboard.GoogleTokens
  import DashboardWeb.CoreComponents
  import DashboardWeb.Ui.Card
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok, assign(socket, %{google_access_token: nil, profile: nil})}
  end

  def update(_assigns, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <%!-- Must not be signed in --%>
        <%= if assigns.profile == nil do %>
          <button phx-click="authorize_google" phx-target={@myself}>
            <.icon name="hero-finger-print" /> Authorize Google
          </button>
        <% end %>
      </.card>
    </div>
    """
  end

  def handle_event("authorize_google", _params, socket) do

  end
end
