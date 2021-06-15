defmodule BeelineAppsignal.AppsignalBehaviour do
  @moduledoc """
  A behavior for the `set_guage/3` function this library uses
  """

  @callback set_guage(String.t(), float() | integer(), map()) :: :ok
end
