defmodule DashboardWeb.Ui.SearchBox do
  use Phoenix.Component

  def search_box(assigns) do
    ~H"""
    <form method="get" action="https://www.google.com/search" target="_blank" class="w-full">
      <div class="relative">
        <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
          <svg
            class="w-5 h-5 text-gray-400"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 20 20"
          >
            <path
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"
            />
          </svg>
        </div>

        <input
          name="q"
          type="search"
          id="search"
          placeholder="Search Google..."
          class="block w-full pl-10 pr-4 py-2 text-sm text-gray-900 placeholder-gray-400 bg-white border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
          required
        />
      </div>
    </form>
    """
  end
end
