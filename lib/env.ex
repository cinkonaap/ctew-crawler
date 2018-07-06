defmodule Env do
  def max_depth(), do: 4
  def max_new_links_per_page(), do: 3
  def max_attempts(), do: 2
  def retry_delay(), do: 3
  def download_delay(), do: 3000
  def error_threshold(), do: 0.2
  def max_concurrent_requests(), do: 3
  def logd(), do: true
end
