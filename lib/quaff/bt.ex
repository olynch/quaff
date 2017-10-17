defmodule Quaff.BT do
  defstruct r: :mt, l: :mt, size: 0

  alias Quaff.BT, as: BT

  defmodule Leaf do
    defstruct val: nil
  end

  import Integer

  def pow(_, 0), do: 1
  def pow(x, n) when Integer.is_odd(n), do: x * pow(x, n - 1)
  def pow(x, n) do
    result = pow(x, div(n, 2))
    result * result
  end

  def from_height(_, _, 0), do: :mt
  def from_height([x], 0, 1), do: %Leaf{val: x}
  def from_height(xs, height, size) do
    pref_size = pow(2, height - 1)
    if size - pref_size <= 0 do
      %BT{l: from_height(xs, height-1, size), r: :mt, size: size}
    else
      {pref, suff} = Enum.split(xs, pref_size)
      %BT{l: from_height(pref, height-1, pref_size), r: from_height(suff, height-1, size - pref_size), size: size}
    end
  end

  def new([]), do: :mt

  def new(xs) do
    size = length(xs)
    height = round(Float.ceil(:math.log2(size/1.0)))
    from_height(xs, height, size)
  end

  def size(%BT{size: size}), do: size
  def size(%Leaf{}), do: 1

  def at(:mt, _), do: :error
  def at(%Leaf{val: val}, 0), do: {:ok, val}
  def at(%BT{l: l, r: r, size: size}, idx) do
    cond do
      idx < size(l) -> at(l, idx)
      idx < size -> at(r, idx - size(l))
      true -> :error
    end
  end

  def set(:mt, _, _), do: :mt
  def set(%Leaf{}, 0, val), do: %Leaf{val: val}
  def set(%BT{l: %Leaf{}, r: r, size: size}, 0, val) do
    %BT{l: %Leaf{val: val}, r: r, size: size}
  end
  def set(%BT{l: l, r: r, size: size}, idx, val) do
    cond do
      idx < l.size -> %BT{l: set(l, idx, val), r: r, size: size}
      idx < size -> %BT{l: l, r: set(r, idx - l.size, val), size: size}
      true -> %BT{l: l, r: r, size: size}
    end
  end

  def to_list(:mt), do: []
  def to_list(%Leaf{val: val}), do: [val]
  def to_list(%BT{l: l, r: r}), do: Enum.concat(to_list(l), to_list(r))
end
