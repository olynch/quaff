defmodule Quaff.QMap do
  alias Quaff.QT, as: QT
  alias Quaff.QMap, as: QMap

  defstruct tree: QT.new([[nil]]), ydim: 1, xdim: 1

  def new(tiles, xdim, ydim), do: %QMap{tree: QT.new(tiles), xdim: xdim, ydim: ydim}

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

  def disp(qmap, tlc, brc, {offsety, offsetx}) do
    for {tile, {y,x}} <- iter_rect(qmap, tlc, brc) do
      :cecho.mvaddch(y + offsety, x + offsetx, tile.char)
    end
  end 
end
