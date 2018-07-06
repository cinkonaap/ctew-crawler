defmodule Crawler.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        Crawler.Server,
        Crawler.RateLimiter,
        Crawler.DownloaderSupervisor
      ],
      strategy: :rest_for_one,
      name: __MODULE__
    )
  end
end
