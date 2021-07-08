defmodule ZenatonEngineTest do
  use ExUnit.Case, async: true

  test "update heart_beat_period" do
    assert ZenatonEngine.update_heart_beat_period(4) == :ok
  end

  test "increment messages_in_hadoc" do
    assert ZenatonEngine.increment_messages_in_hadoc("agent_1") == :ok
  end
end
