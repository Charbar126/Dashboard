# https://www.alphavantage.co/documentation/
defmodule Dashboard.Api.StockApi do
  alias HTTPoison

  def get_time_series_daily(stock_ticker \\ "AAPL") do
    url =
      "#{Dotenv.get("ALPHAVANTAGE_API_URL")}=TIME_SERIES_DAILY&symbol=#{stock_ticker}&apikey=#{Dotenv.get("ALPHAVANTAGE_API_KEY")}"

    IO.inspect(url)

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Received status code #{status_code}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end
end
