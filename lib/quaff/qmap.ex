defmodule Quaff.QMap do
  defstruct tree: :mt, xmax: 0, ymax: 0

  alias Quaff.BT, as: BT
  alias Quaff.QMap, as: QMap

  def new(tiles, xmax, ymax), do: %QMap{tree: BT.new(tiles), xmax: xmax, ymax: ymax}

  def set(%QMap{tree: bt, xmax: xmax}, x, y, square) do
    %QMap{tree: BT.set(bt, xmax * y + x, square), xmax: xmax}
  end

  def at(%QMap{tree: bt, xmax: xmax}, x, y) do
    BT.at(bt, xmax * y + x)
  end
end
