defmodule Crawler.Server do
  @moduledoc """
  Orchestrates the crawling process.

  The process manages the work queue and spawns new workers.
  """

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def download(url) do
    attempt =
      url
      |> Crawler.normalize_url()
      |> Crawler.Attempt.new(1, 1)

    GenServer.cast(__MODULE__, {:download, attempt})
  end

  def download_complete(attempt, page) do
    GenServer.cast(__MODULE__, {:download_complete, attempt, page})
  end

  def init(_args) do
    {:ok, Crawler.PageCache.new()}
  end

  defp spawn_download(cache, attempt) do
    {:ok, pid} = Crawler.DownloaderSupervisor.spawn_download(attempt)
    Process.monitor(pid)
    Crawler.PageCache.start_download(cache, pid, attempt)
  end

  def handle_cast({:download, attempt}, cache) do
    {:noreply, spawn_download(cache, attempt)}
  end

  def handle_cast({:download_complete, attempt, page}, cache) do
    Crawler.log(:green, "#{attempt} -> OK, #{length(page.links)} links")

    cache = Crawler.PageCache.download_complete(cache, attempt, page)

    cache =
      page.links
      |> Enum.filter(fn link ->
        cond do
          Crawler.different_host?(attempt.url, link) ->
            # TEST: do not print, too many external links
            # Crawler.logd(:faint, "#{link} - different host, skipping")
            false

          Crawler.PageCache.downloading?(cache, link) ->
            Crawler.logd(:faint, "#{link} - already processed, skipping")
            false

          attempt.depth == Env.max_depth() ->
            Crawler.logd(:faint, "#{link} - max depth reached (#{Env.max_depth()}), skipping")
            false

          true ->
            true
        end
      end)
      |> Enum.take(Env.max_new_links_per_page())
      |> Enum.reduce(cache, fn link, cache ->
        Crawler.logd(:white, "#{link} - downloading")
        spawn_download(cache, Crawler.Attempt.new(link, attempt.depth + 1, 1))
      end)

    {:noreply, cache}
  end

  def handle_info({:DOWN, _ref, :process, pid, :normal}, cache) do
    {:noreply, Crawler.PageCache.process_complete(cache, pid)}
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, cache) do
    {cache, attempt} = Crawler.PageCache.download_failed(cache, pid)
    Crawler.log(:yellow, "#{attempt} -> FAILED")

    cache =
      if attempt.number < Env.max_attempts() do
        Crawler.logd(:magenta, "retrying in #{Env.retry_delay()}s")
        Process.send_after(self(), {:retry, attempt}, Env.retry_delay() * 1000)
        cache
      else
        Crawler.logd(:red, "no further retries")
        Crawler.PageCache.download_complete(cache, attempt, reason)
      end

    {:noreply, cache}
  end

  def handle_info({:retry, attempt}, cache) do
    {:noreply, spawn_download(cache, Crawler.Attempt.next(attempt))}
  end
end
