defmodule DashboardWeb.Ui.Card do
  use Phoenix.Component

  # Slot for content
  slot :inner_block, required: false

  def card(assigns) do
    ~H"""
    <div class="max-w-md p-6 bg-white rounded-lg shadow-md bordermax-w-md p-6 bg-white rounded-lg shadow-md border">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
