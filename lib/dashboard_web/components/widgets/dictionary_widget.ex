defmodule DashboardWeb.Components.Widgets.DictionaryWidget do
  use Phoenix.LiveComponent
  alias Dashboard.Api.DictionaryApi, as: DictionaryAPI
  import DashboardWeb.CoreComponents
  import DashboardWeb.Ui.Card

  def update(assigns, socket) do
    {:ok, assign(socket, search_word: "", result: nil, error: nil)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <div class="flex items-center gap-2">
          <.icon name="hero-book-open" />
          <h2 class="text-lg font-semibold">Dictionary</h2>
        </div>

        <form phx-submit="search_word" phx-target={@myself} class="mt-2 space-y-2">
          <input
            type="text"
            name="search_word"
            id="search_word"
            value={@search_word}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 placeholder-gray-400"
            placeholder="Enter a word"
          />
          <button type="submit" hidden></button>
        </form>

        <%= if @error do %>
          <p class="text-red-500 text-sm mt-2">The word cannot be found</p>
        <% end %>

        <%= if @result do %>
          <div class="mt-4 space-y-2">
            <h3 class="text-base font-bold">
              {@result["word"]} <small>{@result["phonetic"]}</small>
            </h3>
            <%= for meaning <- @result["meanings"] do %>
              <div class="mt-2">
                <p class="font-semibold capitalize">{meaning["partOfSpeech"]}</p>
                <ul class="list-disc list-inside text-sm space-y-1">
                  <%= for def <- meaning["definitions"] do %>
                    <li>
                      {def["definition"]}
                      <%= if def["example"] do %>
                        — <em>"{def["example"]}"</em>
                      <% end %>
                    </li>
                  <% end %>
                </ul>
              </div>
            <% end %>
          </div>
        <% end %>
      </.card>
    </div>
    """
  end

  def handle_event("search_word", %{"search_word" => word}, socket) do
    case DictionaryAPI.get_word_definition(String.trim(word)) do
      {:ok, [result | _]} ->
        # just pick the first result (common pattern)
        {:noreply, assign(socket, search_word: nil, result: result, error: nil)}

      {:error, reason} ->
        {:noreply,
         assign(socket, search_word: nil, result: nil, error: "Error: #{inspect(reason)}")}
    end
  end
end
