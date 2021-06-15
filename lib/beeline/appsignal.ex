defmodule Beeline.Appsignal do
  @moduledoc """
  an Appsignal exporter for Beeline telemetry
  """

  @appsignal Application.get_env(:beeline_appsignal, :appsignal, Appsignal)

  use Task

  @doc false
  def start_link(opts) do
    Task.start_link(__MODULE__, :attach, [opts])
  end

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
      metadata[:current_position] - metadata[:prior_position],
      %{
        module: inspect(metadata[:producer]),
        hostname: metadata[:hostname]
      }
    )

    state
  end
end
