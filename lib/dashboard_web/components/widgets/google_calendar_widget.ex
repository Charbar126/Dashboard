defmodule DashboardWeb.Components.Widgets.GoogleCalendarWidget do
  use Phoenix.LiveComponent
  import DashboardWeb.Ui.Card
  alias DashboardWeb.GoogleController

  def update(%{google_access_token: access_token}, socket) do
    case GoogleController.get_google_calendar(access_token) do
      {:ok, [%{"Events" => events} | _]} ->
        # IO.inspect(events, label: "Google Events assigned to socket")
        {:ok, assign(socket, google_events: events, google_access_token: access_token)}

      {:ok, _} ->
        IO.inspect("No events fetched")
        {:ok, assign(socket, google_events: [], google_access_token: access_token)}

      {:error, reason} ->
        IO.inspect(reason, label: "Error fetching events")
        {:ok, assign(socket, google_events: [], google_access_token: access_token)}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <h3 class="text-lg font-bold mb-4">Today's Schedule</h3>

    <!-- Calendar Container -->
        <div
          id="calendar-scroll"
          phx-hook="AutoScrollToNow"
          class="relative bg-gray-50 rounded-lg overflow-y-auto max-h-[400px] min-h-[400px] opacity-0 transition-opacity duration-500 scrollbar-hide"
        >
          <div class="relative" style="height: 1728px;">
            <!-- Hour Lines -->
            <%= for hour <- 0..23 do %>
              <div
                class="absolute left-0 w-full border-t border-gray-300 text-xs text-gray-500"
                style={"top: #{(hour) * (100 / 24)}%;"}
              >
                <div class="pl-2">
                  {format_hour(hour)}
                </div>
              </div>
            <% end %>

            <!-- Events -->
            <%= for event <- @google_events do %>
              <% offset = event_offset(event) %>
              <% height = event_height(event) %>

              <div
                class="absolute bg-blue-200 border-l-4 border-blue-600 rounded-md shadow-md text-xs p-2"
                style={"top: #{offset}%; left: 80px; right: 10px; height: #{height}%; min-height: 20px;"}
              >
                <div class="font-semibold truncate">
                  {event["summary"] || "No Title"}
                </div>
                <div class="text-gray-700">
                  {format_event_time(event)}
                </div>
              </div>
            <% end %>

            <!-- Current Time Line -->
            <div
              id="now-line"
              class="absolute w-full border-t-2 border-red-500"
              style={"top: #{current_time_offset()}%;"}
            >
            </div>
          </div>
        </div>
      </.card>
    </div>
    """
  end

  # NOTE: THE OFFSET IS BY SCREENSIZE THIS NEED TO BE DYNAMIC
  defp format_hour(hour) do
    am_pm = if hour < 12, do: "AM", else: "PM"
    hr12 = rem(hour, 12)
    hr12 = if hr12 == 0, do: 12, else: hr12
    "#{hr12}:00 #{am_pm}"
  end

  defp event_offset(event) do
    case parse_datetime(event["start"]) do
      {:ok, %DateTime{} = dt} ->
        total_minutes = dt.hour * 60 + dt.minute
        total_minutes / 1440 * 100

      _ ->
        0
    end
  end

  defp event_height(event) do
    with {:ok, start_dt} <- parse_datetime(event["start"]),
         {:ok, end_dt} <- parse_datetime(event["end"]) do
      duration_minutes = Timex.diff(end_dt, start_dt, :minutes)
      duration_minutes / 1440 * 100
    else
      _ -> 5
    end
  end

  defp current_time_offset do
    now = Timex.now("America/New_York")
    total_minutes = now.hour * 60 + now.minute
    total_minutes / 1440 * 100
  end

  defp parse_datetime(datetime) when is_binary(datetime) do
    with {:ok, dt, _offset} <- DateTime.from_iso8601(datetime),
         local_dt <- Timex.Timezone.convert(dt, "America/New_York") do
      {:ok, local_dt}
    else
      _ -> :error
    end
  end

  defp parse_datetime(_), do: :error

  defp format_event_time(event) do
    with {:ok, start_dt} <- parse_datetime(event["start"]),
         {:ok, end_dt} <- parse_datetime(event["end"]) do
      "#{Timex.format!(start_dt, "{h12}:{m} {AM}")} – #{Timex.format!(end_dt, "{h12}:{m} {AM}")}"
    else
      _ -> "Time unavailable"
    end
  end
end
