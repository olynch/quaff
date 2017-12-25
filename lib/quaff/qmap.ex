defmodule Quaff.QMap do
  alias Quaff.QT, as: QT
  alias Quaff.QMap, as: QMap
  alias Quaff.Tile, as: Tile

  defstruct tree: QT.new([[nil]]), ydim: 1, xdim: 1

  def new(tiles, xdim, ydim) do
    # round up xdim and ydim to closest multiple of 2
    xdim2 = round(:math.pow(2, Float.ceil(:math.log2(xdim))))
    ydim2 = round(:math.pow(2, Float.ceil(:math.log2(ydim))))
    tiles2 = Enum.concat(
      Enum.map(tiles, &(Enum.concat(&1, List.duplicate(%Tile{}, xdim2 - xdim)))),
      List.duplicate(List.duplicate(%Tile{}, xdim2), ydim2 - ydim))
    %QMap{tree: QT.new(tiles2), xdim: xdim, ydim: ydim}
  end

  def set(qmap, {y, x}, square) do
    %QMap{tree: qt, ydim: ydim, xdim: xdim} = qmap
    if y < 0 or y >= ydim or x < 0 or x >= xdim do
      :err
    else
      %QMap{qt | tree: QT.set(qt, {y, x}, square)}
    end
  end

  def set!(qmap, {y, x}, square) do
    %QMap{qmap | tree: QT.set(qmap.tree, {y, x}, square)}
  end

  def at(%QMap{tree: qt, ydim: ydim, xdim: xdim}, {y, x}) do
    if y < 0 or y >= ydim or x < 0 or x >= xdim do
      :err
    else
      {:ok, QT.at(qt, {y, x})}
    end
  end

  def at!(%QMap{tree: qt}, {y, x}) do
    QT.at(qt, {y, x})
  end

  def iter_rect(%QMap{tree: qt}, tlc, brc) do
    QT.iter_rect(qt, tlc, brc)
  end

  def disp(qmap, {offsety, offsetx}) do
    for y <- 0..(qmap.ydim - 1) do
      for x <- 0..(qmap.xdim - 1) do
        Termbox.change_cell(x + offsetx, y + offsety, QMap.at!(qmap, {y,x}).char, 0, 0)
      end
    end
  end 
end
