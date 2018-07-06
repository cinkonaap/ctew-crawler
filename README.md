# Crawler

Sample implementation of a web crawler. Part of the presentation "Concurrency the easy way: Elixir and Erlang VM".

See `lib/env.ex` for tunable runtime params.

## Setup

1. Install Elixir

    ```bash
    $ brew install elixir
    ```

1. Get the dependencies

    ```bash
    $ mix deps.get
    ```

1. Run the application and attach the IEx shell

    ```bash
    $ iex -S mix
    ```

1. Run the observer tool to inspect the application

    ```iex
    iex> :observer.start
    ```

1. Start crawling a web page

    ```iex
    iex> Crawler.Server.download "https://elixir-lang.org"
    ```
