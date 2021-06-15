defmodule BeelineAppsignal.AppsignalBehaviour do
  @moduledoc """
  A behavior for the `set_gauge/3` function this library uses
  """

  @callback set_gauge(String.t(), float() | integer(), map()) :: :ok
end
