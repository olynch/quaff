defmodule Quaff.QT do
  # this is always a complete quadtree -- keeping track of smaller sizes is
  # an optimization for later
  
  defstruct tl: :mt, tr: :mt, bl: :mt, br: :mt, height: 0

  alias Quaff.QT, as: QT
  use Bitwise
  
  defmodule Leaf do
    defstruct val: nil
  end

  defp from_height([[val]], 0), do: %Leaf{val: val}
  defp from_height(grid, height) do
    lower_size = 1 <<< (height - 1)
    {top, bottom} = Enum.split(grid, lower_size)
    [{tl, tr}, {bl, br}] = Enum.map([top, bottom],
      fn half -> Enum.unzip(Enum.map(half, &(Enum.split(&1, lower_size)))) end)
    %QT{
      tl: from_height(tl, height - 1),
      tr: from_height(tr, height - 1),
      bl: from_height(bl, height - 1),
      br: from_height(br, height - 1),
      height: height - 1
    }
  end

  # at and set are mod the size of the tree in both directions

  def at(%Leaf{val: val}, _), do: val
  def at(%QT{tl: tl, tr: tr, bl: bl, br: br, height: h}, {y,x}) do
    top? = (y >>> h) &&& 1
    left? = (x >>> h) &&& 1
    cond do
      (top? == 0) and (left? == 0) -> at(tl, {y, x})
      (top? == 0) and (left? == 1) -> at(tr, {y, x})
      (top? == 1) and (left? == 0) -> at(bl, {y, x})
      (top? == 1) and (left? == 1) -> at(br, {y, x})
    end
  end

  def set(%Leaf{}, _, val), do: %Leaf{val: val}
  def set(qt, {y,x}, val) do
    %QT{tl: tl, tr: tr, bl: bl, br: br, height: h} = qt
    top? = (y >>> h) &&& 1
    left? = (x >>> h) &&& 1
    cond do
      top? == 0 and left? == 0 -> %QT{qt | tl: set(tl, {y,x}, val) }
      top? == 0 and left? == 1 -> %QT{qt | tr: set(tr, {y,x}, val) }
      top? == 1 and left? == 0 -> %QT{qt | bl: set(bl, {y,x}, val) }
      top? == 1 and left? == 1 -> %QT{qt | br: set(br, {y,x}, val) }
    end
  end

  # grid is a 2^n x 2^n list of lists, where n > 0
  
  def new(grid) do
    size = length(grid)
    height = round(Float.ceil(:math.log2(size/1.0)))
    from_height(grid, height)
  end

  def from_list(grid), do: new(grid)

  defp hcombine(ll, rl) do
    Enum.map(Enum.zip(ll, rl), fn {l, r} -> Enum.concat(l, r) end)
  end

  def to_list(%Leaf{val: val}), do: [[val]]
  def to_list(%QT{tl: tl, tr: tr, bl: bl, br: br}) do
    Enum.concat(hcombine(to_list(tl), to_list(tr)), hcombine(to_list(bl), to_list(br)))
  end
end

