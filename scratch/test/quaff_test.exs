defmodule QuaffTest do
  use ExUnit.Case
  doctest Quaff

  test "greets the world" do
    assert Quaff.hello() == :world
  end
end
