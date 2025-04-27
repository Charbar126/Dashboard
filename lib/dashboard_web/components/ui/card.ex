defmodule DashboardWeb.Ui.Card do
  @moduledoc """
  A reusable UI component for rendering a customizable card layout.

  You can pass custom width, height, padding, and background color if needed.
  Otherwise, it uses nice defaults.
  """

  use Phoenix.Component

  @doc """
  A reusable card container.

  ## Slots
    - `:inner_block` (optional): Content inside the card.

  ## Attributes
    - `:width` (optional): Tailwind width class (default: "max-w-md")
    - `:height` (optional): Tailwind height class (default: "h-auto")
    - `:padding` (optional): Tailwind padding class (default: "p-6")
    - `:background` (optional): Tailwind background color class (default: "bg-white")
  """
  attr :width, :string, default: "max-w-md"
  attr :height, :string, default: "h-auto"
  attr :padding, :string, default: "p-6"
  attr :background, :string, default: "bg-white"
  slot :inner_block, required: false

  def card(assigns) do
    ~H"""
    <div class={"#{@width} #{@height} #{@padding} #{@background} rounded-lg shadow-md border"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
