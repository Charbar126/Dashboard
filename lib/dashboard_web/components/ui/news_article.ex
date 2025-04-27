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
    <a
      href={@article_url}
      target="_blank"
      class="block transition-all hover:shadow-md hover:scale-[1.01] rounded-lg"
    >
      <.card height="h-20" padding="p-2">
        <div class="flex gap-3 items-center h-full overflow-hidden">
          <%= if @image_url do %>
            <img
              src={@image_url}
              alt="News Image"
              class="w-14 h-14 object-cover rounded-md flex-shrink-0"
            />
          <% end %>

          <div class="flex flex-col justify-center text-xs w-full h-full">
            <h2 class="font-semibold truncate text-xs leading-tight">
              {@title}
            </h2>

            <%= if @description do %>
              <p class="italic text-gray-600 text-[11px] leading-snug truncate">
                {@description}
              </p>
            <% end %>

            <div class="text-gray-400 text-[10px] leading-tight truncate">
              Source: {@source}
              <%= if @published_date do %>
                • Published: {@published_date}
              <% end %>
            </div>
          </div>
        </div>
      </.card>
    </a>
    """
  end
end
