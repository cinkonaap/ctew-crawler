defmodule Crawler do
  def download_page!(url) do
    Process.sleep(Env.download_delay())

    page =
      if :rand.uniform() < Env.error_threshold() do
        HTTPoison.get!("bad_link")
      else
        HTTPoison.get!(url).body
      end

    links =
      Floki.attribute(page, "a", "href")
      |> Enum.map(&build_link(url, &1))
      |> Enum.uniq()

    Crawler.Page.new(page, links)
  end

  def build_link(base, link) do
    base
    |> URI.merge(link)
    |> URI.to_string()
    |> normalize_url()
  end

  def normalize_url(url) do
    url
    |> String.downcase()
    |> URI.parse()
    |> Map.put(:fragment, nil)
    |> set_default_path()
    |> URI.to_string()
  end

  defp set_default_path(uri) do
    if uri.path == nil do
      %{uri | path: "/"}
    else
      uri
    end
  end

  def different_host?(url, link) do
    URI.parse(url).host != URI.parse(link).host
  end

  def log(color \\ :white, text) do
    IO.puts("#{apply(IO.ANSI, color, [])}#{text}#{IO.ANSI.reset()}")
  end

  def logd(color \\ :white, text) do
    if Env.logd() do
      IO.puts("#{apply(IO.ANSI, color, [])}  > #{text}#{IO.ANSI.reset()}")
    end
  end
end
