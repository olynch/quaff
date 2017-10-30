defmodule Quaff.QMap do
  alias Quaff.QT, as: QT
  alias Quaff.QMap, as: QMap

  defstruct tree: QT.new([[nil]]), ymax: 0, xmax: 0


  def new(tiles, xmax, ymax), do: %QMap{tree: QT.new(tiles), xmax: xmax, ymax: ymax}

  def set(qmap, {y, x}, square) do
    %QMap{tree: qt, ymax: ymax, xmax: xmax} = qmap
    if y < 0 or y > ymax or x < 0 or x > xmax do
      :err
    else
      %QMap{qt | tree: QT.set(qt, {y, x}, square)}
    end
  end

  def set!(qmap, {y, x}, square) do
    %QMap{qmap | tree: QT.set(qmap.tree, {y, x}, square)}
  end

  def at(%QMap{tree: qt, ymax: ymax, xmax: xmax}, {y, x}) do
    if y < 0 or y > ymax or x < 0 or x > xmax do
      :err
    else
      {:ok, QT.at(qt, {y, x})}
    end
  end

  def at!(%QMap{tree: qt}, {y, x}) do
    QT.at(qt, {y, x})
  end
end
