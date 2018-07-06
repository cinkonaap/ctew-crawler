defmodule Crawler.RateLimiter do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, {Env.max_concurrent_requests(), []}}
  end

  def checkout() do
    GenServer.call(__MODULE__, {:checkout, self()}, :infinity)
  end

  def handle_call({:checkout, pid}, from, {left, waitlist}) do
    if left > 0 do
      Process.monitor(pid)
      {:reply, :ok, {left - 1, waitlist}}
    else
      {:noreply, {left, waitlist ++ [from]}}
    end
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, {left, waitlist}) do
    case waitlist do
      [] ->
        {:noreply, {left + 1, waitlist}}

      [{pid, _ref} = process | rest] ->
        Process.monitor(pid)
        GenServer.reply(process, :ok)
        {:noreply, {left, rest}}
    end
  end
end
