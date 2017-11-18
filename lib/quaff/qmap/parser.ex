defmodule Quaff.QMap.Parser do
  alias Quaff.Tile, as: Tile
  alias Quaff.QMap, as: QMap
  def string_to_tile(s) do
    <<sval::utf8>> = s
    if sval == ?# do
      %Tile{ char: ?#, seethrough: false, passable: false }
    else
      %Tile{ char: sval, seethrough: true, passable: true }
    end
  end
  def parse_qmap(file_name) do
    {:ok, handle} = File.open(file_name, [:utf8, :read])
    lines = IO.stream(handle, :line)
            |> Stream.map(fn str -> (Enum.map(String.codepoints(String.trim(str)), &string_to_tile/1)) end)
            |> Enum.into([])
    ydim = length(lines)
    xdim = length(List.first(lines))
    QMap.new(lines, ydim, xdim)
  end
end
