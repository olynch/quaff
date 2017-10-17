defmodule QuaffBTTest do
  use ExUnit.Case

  alias Quaff.BT, as: BT

  test "binary tree initialize" do
    cases = [[], [1, 2, 3, 5], List.duplicate(9, 90), Enum.to_list(1..90)]
    for xs <- cases do
      assert BT.to_list(BT.new(xs)) == xs
    end
  end

  test "binary tree at" do
    xs = Enum.to_list(0..90)
    bt = BT.new(xs)
    for i <- xs do
      assert BT.at(bt, i) == {:ok, i}
    end
  end

  test "binary tree set" do
  end
end
