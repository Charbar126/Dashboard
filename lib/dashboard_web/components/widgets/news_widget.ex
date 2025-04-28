defmodule DashboardWeb.Components.Widgets.NewsWidget do
  import DashboardWeb.Ui.NewsArticle
  import DashboardWeb.Ui.Card
  use Phoenix.LiveComponent
  alias Dashboard.Api.NewsApi, as: NewsAPI

  def mount(socket), do: {:ok, socket}

  def update(_assigns, socket) do
    case NewsAPI.get_top_headlines() do
      {:ok, raw_data} ->
        {:ok, assign(socket, articles: format_top_headlines(raw_data), error: nil)}

      {:error, _reason} ->
        {:ok, assign(socket, articles: [], error: "Failed to fetch news")}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.card height="">
        <h2 class="text-lg font-bold mb-3">Top Headlines</h2>

        <%= if @error do %>
          <p class="text-red-500 text-sm">Error: {@error}</p>
        <% else %>
          <div class="overflow-y-auto max-h-[calc(100vh-10rem)] space-y-2 pr-1 scrollbar-hide">
            <%= for article <- @articles do %>
              <.news_article
                title={article[:title]}
                source={article[:source]}
                article_url={article[:article_url]}
                description={article[:description]}
                image_url={article[:image_url]}
                published_date={article[:published_date]}
              />
            <% end %>
          </div>
        <% end %>
      </.card>
    </div>
    """
  end

  defp format_top_headlines(%{"articles" => articles}) do
    Enum.map(articles, fn article ->
      %{
        title: article["title"],
        source:
          get_in(article, ["source", "name"]) || get_in(article, ["source", "id"]) || "Unknown",
        article_url: article["url"],
        description: article["description"],
        image_url: article["urlToImage"],
        published_date: format_datetime(article["publishedAt"])
      }
    end)
  end

  defp format_datetime(nil), do: nil

  defp format_datetime(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, dt, _} ->
        "#{dt.month}/#{dt.day}/#{dt.year}"

      _ ->
        datetime
    end
  end
end
