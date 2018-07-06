defmodule Crawler.Page do
  defstruct [:content, :links]

  def new(content, links) do
    %Crawler.Page{content: content, links: links}
  end
end
