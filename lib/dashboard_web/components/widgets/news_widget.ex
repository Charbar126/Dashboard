defmodule DashboardWeb.Components.Widgets.NewsWidget do
  import DashboardWeb.Ui.NewsArticle
  import DashboardWeb.Ui.Card
  use Phoenix.LiveComponent
  alias Dashboard.Api.NewsApi, as: NewsAPI

  def update(_assigns, socket) do
    case NewsAPI.get_top_headlines() do
      {:ok, raw_data} ->
        formatted_data = format_top_headlines(raw_data)
        {:ok, assign(socket, articles: formatted_data)}

      # Possibly change the error
      {:error, _reason} ->
        {:ok, assign(socket, articles: %{error: "Failed to fetch weather data"})}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <%= if @articles[:error] do %>
          <p class="text-red-500">Error: {@articles[:error]}</p>
        <% else %>
          <%= for article <- @articles do %>
            <.news_article
              title={article[:title]}
              source={article[:source]}
              article_url={article[:url]}
              description={article[:description]}
              image={article[:urlToImage]}
              published_date={article[:publishedAt]}
            />
          <% end %>
        <% end %>
      </.card>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  defp format_top_headlines(%{"articles" => articles}) do
    Enum.map(articles, fn article ->
      %{
        title: article["title"],
        source: article["source"]["name"] || article["source"]["id"] || "Unknown",
        description: article["description"],
        url: article["url"],
        image_url: article["urlToImage"],
        published_at: article["publishedAt"]
      }
    end)
  end
end
