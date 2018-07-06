defmodule Crawler.Attempt do
  defstruct [:url, :depth, :number]

  def new(url, depth, number) do
    %Crawler.Attempt{url: url, depth: depth, number: number}
  end

  def next(attempt) do
    %{attempt | number: attempt.number + 1}
  end
end

defimpl String.Chars, for: Crawler.Attempt do
  def to_string(attempt) do
    "#{attempt.url} [d: #{attempt.depth}, a: #{attempt.number}]"
  end
end
