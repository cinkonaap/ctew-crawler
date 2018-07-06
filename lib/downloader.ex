defmodule Crawler.Downloader do
  @moduledoc """
  Downloads a single page and sends the result to the Crawler.Server.
  """

  use GenServer, restart: :temporary, shutdown: :brutal_kill

  def start_link(attempt) do
    GenServer.start_link(__MODULE__, attempt)
  end

  def init(attempt) do
    send(self(), :download)
    {:ok, attempt}
  end

  def handle_info(:download, attempt) do
    Crawler.RateLimiter.checkout()
    page = Crawler.download_page!(attempt.url)
    Crawler.Server.download_complete(attempt, page)
    {:stop, :normal, attempt}
  end
end
