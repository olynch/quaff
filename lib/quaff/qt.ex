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

  # returns a list of tuples {elem, pos} in the intersection of (the rectangle with top-left corner tlcy, tlcx
  # and bottom-right corner brcy brcx) and the tree, where the top leftmost element of the tree is 
  # assumed to be a coordinate 0,0. The tuples are in unspecified order.
  def iter_rect(qt, tlc, brc) do
    iter_rect_pos(qt, tlc, brc, {0,0}, [])
  end

  def iter_rect_pos(%Leaf{val: val}, {tlcy, tlcx}, {brcy, brcx}, {tly, tlx}, rest) do
    if tly >= tlcy and tlx >= tlcx and tlx <= brcy and tly <= brcx do
      [{val, {tly, tlx}} | rest]
    else
      rest
    end
  end

  def iter_rect_pos(
    %QT{tl: tl, tr: tr, bl: bl, br: br, height: height},
    {tlcy, tlcx}, {brcy, brcx}, {tly, tlx}, rest) do
      tlc = {tlcy, tlcx}
      brc = {brcy, brcx}
      dim = 1 <<< height
      subdim = 1 <<< (height - 1)
      # if the entire tree is outside of the rectangle, don't do anything
      if tlcy >= tly + dim or tlcx >= tlx + dim or brcy < tly or brcx < tlx do
        rest
      else
        iter_rect_pos(
          tl, tlc, brc, {tly, tlx}, iter_rect_pos(
            tr, tlc, brc, {tly, tlx + subdim}, iter_rect_pos(
              bl, tlc, brc, {tly + subdim, tlx}, iter_rect_pos(
                br, tlc, brc, {tly + subdim, tlx + subdim}, rest
              )
            )
          )
        )
      end
  end
end

