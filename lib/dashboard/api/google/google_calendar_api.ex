defmodule Dashboard.Api.Google.GoogleCalendarApi do
  @doc """
  Gets the current day's events.
  """
  def fetch_today_events(access_token) do
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    # Get primary calendar metadata to extract calendar_id
    {:ok, %{"id" => calendar_id}} =
      HTTPoison.get("https://www.googleapis.com/calendar/v3/calendars/primary", headers)
      # |> IO.inspect(label: "Raw Calendar API Response")
      |> parse_body_response()

    # Get the start and end of *today* in RFC3339 format
    start_cal = Timex.beginning_of_day(Timex.now("America/New_York"))
    end_cal = Timex.end_of_day(start_cal)

    params = %{
      timeMin: Timex.format!(start_cal, "{RFC3339}"),
      timeMax: Timex.format!(end_cal, "{RFC3339}"),
      singleEvents: true,
      orderBy: "startTime"
    }

    {:ok, %{"items" => event_list}} =
      HTTPoison.get(
        "https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events",
        headers,
        params: params
      )
      # |> IO.inspect(label: "Events API Response")
      |> parse_body_response()

    reshaped = reshape_gcal_data(event_list)
    {:ok, reshaped}
  end

  def reshape_gcal_data(event_list) do
    formatted_map =
      for event <- event_list do
        [meeting_date, start_time, end_time] =
          if Map.get(event, "start", %{})["dateTime"] do
            [meeting_date, _] = String.split(event["start"]["dateTime"], "T")
            [meeting_date, event["start"]["dateTime"], event["end"]["dateTime"]]
          else
            [event["start"]["date"], "All Day", "All Day"]
          end

        attendees =
          case Map.get(event, "attendees") do
            nil -> []
            attendees -> Enum.map(attendees, & &1["email"])
          end

        summary = Map.get(event, "summary", "No Title")

        %{
          "Date" => meeting_date,
          "Details" => %{
            "attendees" => attendees,
            "summary" => summary,
            "start" => start_time,
            "end" => end_time
          }
        }
      end

    formatted_map
    |> Enum.group_by(& &1["Date"])
    |> Enum.map(fn {date, events} ->
      %{
        "Date" => date,
        "Events" => Enum.map(events, & &1["Details"])
      }
    end)
  end

  defp parse_body_response({:error, err}), do: {:error, err}

  defp parse_body_response({:ok, %HTTPoison.Response{body: body}}) do
    with {:ok, parsed} <- Jason.decode(body) do
      {:ok, parsed}
    end
  end
end
