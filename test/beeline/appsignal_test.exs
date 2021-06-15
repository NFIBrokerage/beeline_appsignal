defmodule Beeline.AppsignalTest do
  use ExUnit.Case

  import Mox
  setup :verify_on_exit!
  setup :set_mox_global
  @appsignal Application.compile_env!(:beeline_appsignal, :appsignal)

  alias BeelineAppsignal.MyHandler

  setup do
    [self: self()]
  end

  test "the health checker periodically checks position and aliveness", c do
    gauge_name = "event_listener_lag"

    stub(@appsignal, :set_gauge, fn gauge_name, delta, metadata ->
      send(c.self, {:set_gauge, gauge_name, delta, metadata})

      :ok
    end)

    event = %{foo: "bar"}
    events = [event, event]

    _exporter = start_supervised!({Beeline.Appsignal, gauge_name: gauge_name})
    _topology = start_supervised!({MyHandler, test_proc: c.self})

    Beeline.test_events(events, MyHandler)
    assert_receive {:handled, [^event]}
    assert_receive {:handled, [^event]}

    assert_receive {:set_gauge, ^gauge_name, 0, metadata}, 200
    assert metadata.hostname |> is_binary()
    assert metadata.module == "BeelineAppsignal.MyHandler.Producer_default"
  end
end
