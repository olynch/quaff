defmodule QuaffServerTest do
  use ExUnit.Case
  doctest QuaffServer

  test "greets the world" do
    assert QuaffServer.hello() == :world
  end
end
