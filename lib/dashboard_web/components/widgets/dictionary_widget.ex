defmodule DashboardWeb.Components.Widgets.DictionaryWidget do
  use Phoenix.LiveComponent
  alias Dashboard.Api.DictionaryApi, as: DictionaryAPI
  import DashboardWeb.CoreComponents
  import DashboardWeb.Ui.Card

  def update(_assigns, socket) do
    {:ok, assign(socket, search_word: "", result: nil, error: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="relative">
      <.card width="w-full" height="h-full">
        <div class="flex flex-col h-full">
          <!-- Title -->
          <div class="flex items-center gap-2 mb-4">
            <.icon name="hero-book-open" class="w-6 h-6 text-blue-500" />
            <h2 class="text-xl font-bold">Dictionary</h2>
          </div>

          <form phx-submit="search_word" phx-target={@myself} class="space-y-2">
            <input
              type="text"
              name="search_word"
              id="search_word"
              value={@search_word}
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 w-full p-2 placeholder-gray-400"
              placeholder="Enter a word..."
            />
            <button type="submit" hidden></button>
          </form>

          <%= if @error do %>
            <p class="text-red-500 text-sm mt-4">The word could not be found.</p>
          <% end %>
        </div>
      </.card>

      <%= if @result do %>
        <div
          id="dictionary-modal"
          phx-hook="ModalCloser"
          class="fixed inset-0 bg-black bg-opacity-30 flex items-start justify-center pt-20 z-50 "
        >
          <div
            class="bg-white rounded-lg shadow-lg w-full max-w-2xl max-h-[80vh] overflow-y-auto p-6 relative scrollbar-hide"
            phx-target={@myself}
          >
            <!-- Close Button -->
            <button
              phx-click="close_modal"
              phx-target={@myself}
              class="absolute top-2 right-2 text-gray-500 hover:text-gray-700"
            >
              ✖
            </button>

            <div>
              <h3 class="text-2xl font-bold">
                {@result["word"]}
                <%= if @result["phonetic"] do %>
                  <span class="text-gray-500 text-lg ml-2">[{@result["phonetic"]}]</span>
                <% end %>
              </h3>
            </div>

            <div class="mt-6 space-y-4">
              <%= for meaning <- @result["meanings"] do %>
                <div class="space-y-2">
                  <p class="text-base font-semibold capitalize text-blue-600">
                    {meaning["partOfSpeech"]}
                  </p>
                  <ul class="list-disc list-inside text-sm text-gray-700 leading-snug space-y-1">
                    <%= for def <- meaning["definitions"] do %>
                      <li>
                        <span>{def["definition"]}</span>
                        <%= if def["example"] do %>
                          <span class="italic text-gray-500">— "{def["example"]}"</span>
                        <% end %>
                      </li>
                    <% end %>
                  </ul>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, result: nil)}
  end

  def handle_event("search_word", %{"search_word" => word}, socket) do
    case DictionaryAPI.get_word_definition(String.trim(word)) do
      {:ok, [result | _]} ->
        {:noreply, assign(socket, search_word: "", result: result, error: nil)}

      {:error, reason} ->
        {:noreply,
         assign(socket, search_word: "", result: nil, error: "Error: #{inspect(reason)}")}
    end
  end
end
