defmodule DashboardWeb.Ui.Card do
  @moduledoc """
  A reusable UI component for rendering a card layout.

  This component provides a styled container for displaying content within
  a card format, making it easy to reuse across different parts of the dashboard.
  """

  use Phoenix.Component

  @doc """
  Defines a slot for the card's inner content and renders a card component with a shadow, padding, and rounded corners.

  This slot allows other components to pass content that will be rendered inside the card. The card acts as a container for any content provided via the `:inner_block` slot.

  ## Slots
    - `:inner_block` (optional): The content to be displayed inside the card.

  ## Parameters
    - `assigns`: The Phoenix assigns that may contain an `:inner_block` slot.

  ## Returns
    - HEEx template rendering a styled card.
  """
  slot :inner_block, required: false

  def card(assigns) do
    ~H"""
    <div class="max-w-md p-6 bg-white rounded-lg shadow-md border">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
