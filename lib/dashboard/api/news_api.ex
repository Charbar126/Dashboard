defmodule Dashboard.Api.NewsApi do
  alias HTTPoison

  def get_top_headlines(country \\ "us") do
    url = "#{Dotenv.get("NEWS_API_URL")}?country=#{country}&apiKey=#{Dotenv.get("NEWS_API_KEY")}"

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
