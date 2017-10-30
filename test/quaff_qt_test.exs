defmodule QuaffQTTest do
  use ExUnit.Case

  alias Quaff.QT, as: QT

  test "quadtree new" do
    cases = [[[1]], [[1,2],[3,4]], [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]]
    for grid <- cases do
      assert QT.to_list(QT.new(grid)) == grid
    end
  end

  test "quadtree at" do
    cases = [[[1]], [[1,2],[3,4]], [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]]
    for grid <- cases do
      l = length(grid)
      qt = QT.new(grid)
      for y <- 0..(l-1) do
        for x <- 0..(l-1) do
          assert QT.at(qt, {y,x}) == Enum.at(Enum.at(grid, y), x)
        end
      end
    end
  end

  defp set_all(qt, []), do: qt
  defp set_all(qt, [{pos, val} | rest]) do
    set_all(QT.set(qt, pos, val), rest)
  end

  test "quadtree set" do
    qt = QT.new([[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]])
    new_values = [{{3, 2}, 90}, {{0, 0}, 91}, {{2, 3}, 0}]
    new_qt = set_all(qt, new_values)
    for {{y, x}, val} <- new_values do
      assert QT.at(new_qt, {y, x}) == val
    end
  end
end
