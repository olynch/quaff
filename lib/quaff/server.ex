defmodule Quaff.Server do
  @moduledoc """
  The server for quaff. Does everything except for user interaction
  """

  use GenServer
  alias Quaff.Player, as: Player
  alias Quaff.QMap, as: QMap
  alias Quaff.Tile, as: Tile
  alias Quaff.Update, as: Update

  defmodule State do
    defstruct players: %{}, map: QMap.new([[%Tile{}]], 1, 1)
  end

  def make_update(state, resend_map) do
    %Update{ players: state.players, map: (if resend_map, do: {:ok, state.map}, else: nil) }
  end

  def broadcast(state, resend_map) do
    for pid <- Map.keys(state.players) do
      send pid, { :update, make_update(state, resend_map) }
    end
  end

  def move(pid, direction, state) do
    case state.players[pid] do
      nil -> state
      p ->
        %Player{y: y, x: x} = p
        {dy, dx} = case direction do
          :up -> {-1, 0}
          :down -> {1, 0}
          :left -> {0, -1}
          :right -> {0, 1}
          :ul -> {-1, -1}
          :ur -> {-1, 1}
          :dl -> {1, -1}
          :dr -> {1, 1}
        end
        {newy, newx} = {y + dy, x + dx}
        case QMap.at(state.map, {newy, newx}) do
          {:ok, %Tile{ passable: true }} -> 
            case Enum.find(Map.to_list(state.players), &(elem(&1, 1).y == newy and elem(&1, 1).x == newx)) do
              nil -> %State{ state | players: Map.replace(state.players, pid, %Player{ p | x: newx, y: newy}) }
              {otherpid, otherp} -> 
                %State{ state |
                  players: Map.replace(state.players, otherpid, %Player{ otherp | hp: otherp.hp - p.attack }) }
            end
          {:ok, %Tile{ passable: false }} -> state
          :err -> state
        end
    end
  end

  def start_link(map_file) do
    GenServer.start_link(
      __MODULE__,
      %State{map: Quaff.QMap.Parser.parse_qmap(map_file)},
      name: __MODULE__)
  end

  def init(x,y) do
    GenServer.call __MODULE__, {:init, x, y}
  end

  def move(dir) do
    GenServer.call __MODULE__, {:move, dir}
  end

  def drop do
    GenServer.call __MODULE__, :drop
  end

  def status do
    GenServer.call __MODULE__, :status
  end

  def handle_call({:init, x, y}, {from, _}, state) do
    new_state = %State{state | players: Map.put(state.players, from, %Player{x: x, y: y})}
    spawn(__MODULE__, :broadcast, [new_state, false])
    {:reply, make_update(new_state, true), new_state}
  end

  def handle_call(:drop, {from, _}, state) do
    new_state = %State{state | players: Map.delete(state.players, from)}
    spawn(__MODULE__, :broadcast, [new_state, false])
    {:reply, :ok, new_state}
  end

  def handle_call({:move, direction}, {from, _}, state) do
    new_state = move(from, direction, state)
    spawn(Quaff.Server, :broadcast, [new_state, false])
    {:reply, :ok, new_state}
  end

  def handle_call(:status, {_, _}, state) do
    {:reply, make_update(state, true), state}
  end
end
