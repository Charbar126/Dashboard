defmodule DashboardWeb.SearchEngine do
  use Phoenix.LiveView
  import DashboardWeb.Ui.SearchBox

  @search_engines %{
    google: "https://www.google.com/search?q=",
    bing: "https://www.bing.com/search?q=",
    yahoo: "https://search.yahoo.com/search?p="
  }

  def render(assigns) do
    ~H"""
      <.search_box />
    """
  end

  # Handle the form submission
  def handle_event("search", %{"query" => query}, socket) do
    selected_engine = socket.assigns.selected_engine || "google"
    search_url = Map.get(@search_engines, String.to_atom(selected_engine)) <> URI.encode(query)

    # Redirect to the search engine with the query
    {:noreply, redirect(socket, external: search_url)}
  end
end
