defmodule DashboardWeb.Components.Widgets.GoogleAuthetnicationWidget do
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
        <button phx-click="authorize_google" phx-target={@myself}>
          <.icon name="hero-finger-print" /> Authorize Google
        </button>
      </.card>
    </div>
    """
  end

  def handle_event("authorize_google", _params, socket) do
    {:noreply, redirect(socket, external: "/auth/google")}
  end
end
