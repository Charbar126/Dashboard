  defmodule DashboardWeb.Components.Widgets.StockWidget do
    import DashboardWeb.Ui.Card
    use Phoenix.LiveComponent
    alias Dashboard.Api.StockApi, as: StockAPI

    # Update is called on mount(intal loading and after even handling is called)
    def update(_assigns, socket) do
      case StockAPI.get_time_series_daily() do
        {:ok, raw_data} ->
          formatted_data = format_daily_time_series(raw_data)
          {:ok, assign(socket, stock_data: formatted_data)}

        # Prob need to reformat
        {:error, _reason} ->
          {:ok, assign(socket, stock_data: %{error: "Failed to fetch stock data"})}
      end
    end

    def render(assigns) do
      ~H"""
      <div>
        <.card>
          <p>Stock Widget</p>
          <%= if @stock_data[:error] do %>
            <p>Error: {@stock_data[:error]}</p>
          <% else %>
            <p>Stock: {@stock_data.symbol}</p>
            <p>Last Refreshed: {@stock_data.last_refreshed}</p>
            <p>Open: ${@stock_data.open}</p>
            <p>High: ${@stock_data.high}</p>
            <p>Low: ${@stock_data.low}</p>
            <p>Close: ${@stock_data.close}</p>
            <p>Volume: {@stock_data.volume}</p>
          <% end %>
        </.card>
      </div>
      """
    end

    defp format_daily_time_series(%{
          "Meta Data" => %{
            "2. Symbol" => symbol,
            "3. Last Refreshed" => last_refreshed
          },
          "Time Series (Daily)" => time_series
        }) do
      case Map.get(time_series, last_refreshed) do
        nil ->
          %{error: "No data available for #{last_refreshed}"}

        %{
          "1. open" => open,
          "2. high" => high,
          "3. low" => low,
          "4. close" => close,
          "5. volume" => volume
        } ->
          %{
            symbol: symbol,
            last_refreshed: last_refreshed,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
          }
      end
    end
  end
