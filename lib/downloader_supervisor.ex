defmodule Crawler.DownloaderSupervisor do
  @moduledoc """
  Supervises downloader workers.
  """

  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def spawn_download(attempt) do
    DynamicSupervisor.start_child(__MODULE__, {Crawler.Downloader, attempt})
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one, max_children: :infinity)
  end
end
