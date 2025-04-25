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
        <h3 class="text-xl font-bold">Today's Events</h3>
        <ul class="space-y-2 mt-4">
          <%= for event <- @google_events do %>
            <li class="border rounded p-3 shadow-sm bg-white text-sm text-gray-700">
              <strong>{event["summary"] || "No Title"}</strong> <br />
              {format_event_time(event)}
            </li>
          <% end %>
        </ul>
      </.card>
    </div>
    """
  end

  defp format_event_time(event) do
    start_time = event["start"]
    end_time = event["end"]

    with {:ok, start_dt} <- parse_datetime(start_time),
         {:ok, end_dt} <- parse_datetime(end_time) do
      "#{Timex.format!(start_dt, "{h12}:{m} {AM}")} – #{Timex.format!(end_dt, "{h12}:{m} {AM}")}"
    else
      _ -> "Time unavailable"
    end
  end

  defp parse_datetime(%{"dateTime" => datetime}), do: Timex.parse(datetime, "{ISO:Extended}")
  defp parse_datetime(%{"date" => date}), do: Timex.parse(date, "{YYYY}-{0M}-{0D}")
  defp parse_datetime(_), do: :error
end
