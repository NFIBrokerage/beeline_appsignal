defmodule Beeline.Appsignal do
  @moduledoc """
  an Appsignal exporter for Beeline telemetry

  This exporter works by attaching a telemetry handler. This means that the
  code to set the gauge runs in the process of the HealthChecker.

  Attach this exporter by adding this task to a supervision tree, for example
  the application supervision tree defined in the `lib/my_app/application.ex`
  file:

  ```elixir
  def start(_type, _args) do
    children = [
      {Beeline.Appsignal, []},
      MyApp.MyBeelineTopology
    ]
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
  ```

  This exporter sets an Appsignal gauge measuring the difference between
  the latest available event number and the current position given by the
  Beeline's `:get_stream_position` function option. This gauge is tagged
  with the name of the producer under the key `:module` and the hostname
  on which the producer is running under the key `:hostname`.

  ## Options

  The `start_link/1` function takes a keyword list of options. These can also
  be specified by passing the keyword as the second element of a tuple given
  to a `Supervisor.start_link/2` list of children.

  * `:gauge_name` (string, default: `"event_listener_lag"`) - the gauge name
    to which the delta should be published
  """

  @appsignal Application.compile_env(:beeline_appsignal, :appsignal, Appsignal)

  use Task

  @doc false
  def start_link(opts) do
    Task.start_link(__MODULE__, :attach, [opts])
  end

  @doc false
  def attach(opts) do
    :telemetry.attach(
      "beeline-appsignal-exporter",
      [:beeline, :health_check, :stop],
      &__MODULE__.handle_event/4,
      opts
    )
  end

  @doc false
  def handle_event(_event, _measurement, metadata, state) do
    @appsignal.set_gauge(
      state[:gauge_name] || "event_listener_lag",
      metadata[:head_position] - metadata[:current_position],
      %{
        module: inspect(metadata[:producer]),
        hostname: metadata[:hostname]
      }
    )

    state
  end
end
