defmodule DashboardWeb.Ui.NewsArticle do
  import DashboardWeb.Ui.Card
  use Phoenix.Component

  attr :title, :string, required: true
  attr :source, :string, required: true
  attr :article_url, :string, required: true
  attr :description, :string, required: false
  attr :image_url, :string, required: false
  attr :published_date, :string, required: false

  def news_article(assigns) do
    ~H"""
    <div>
      <.card>
        <h2 class="text-lg font-bold">{@title}</h2>
        <p class="text-sm text-gray-500">Source: {@source}</p>
        <a href={@article_url} class="text-blue-600 hover:underline">Read more</a>
        <%= if @description do %>
          <p class="mt-2 text-gray-700">{@description}</p>
        <% end %>
        <%= if @image_url do %>
          <img src={@image_url} alt="News Image" class="mt-2 w-full h-48 object-cover rounded-lg" />
        <% end %>
        <%= if @published_date do %>
          <p class="text-xs text-gray-400 mt-2">Published: {@published_date}</p>
        <% end %>
      </.card>
    </div>
    """
  end
end
