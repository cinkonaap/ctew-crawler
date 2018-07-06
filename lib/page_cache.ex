defmodule Crawler.PageCache do
  defstruct pages: %{}, attempts: %{}

  def new() do
    %Crawler.PageCache{}
  end

  def start_download(cache, pid, attempt) do
    %{
      cache
      | pages: Map.put(cache.pages, attempt.url, nil),
        attempts: Map.put(cache.attempts, pid, attempt)
    }
  end

  def download_complete(cache, attempt, page) do
    %{cache | pages: Map.put(cache.pages, attempt.url, page)}
  end

  def process_complete(cache, pid) do
    %{cache | attempts: Map.delete(cache.attempts, pid)}
  end

  def download_failed(cache, pid) do
    {attempt, attempts} = Map.pop(cache.attempts, pid)
    {%{cache | attempts: attempts}, attempt}
  end

  def downloading?(cache, url) do
    Map.has_key?(cache.pages, url)
  end
end
