# Beeline.Appsignal

![Actions CI](https://github.com/NFIBrokerage/beeline_appsignal/workflows/Actions%20CI/badge.svg)

an Appsignal.io exporter for Beeline telemetry

This exporter publishes the difference between the latest event number in a
producer's stream and the current stream position of the producer. This can
be used to create graphs and anomaly triggers in Appsignal to notify you
when a producer falls behind.

## Installation

```elixir
def deps do
  [
    {:beeline_appsignal, "~> 0.1"}
  ]
end
```

Check out the docs here: https://hexdocs.pm/beeline_appsignal

## Usage

Add the `Beeline.Appsignal` task to your application's supervision tree

```elixir
# lib/my_app/application.ex
defmodule MyApp.Application do
  # ..

  def start(_type, _args) do
    children = [
      # ..
      Beeline.Appsignal,
      # ..
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```
