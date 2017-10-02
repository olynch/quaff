defmodule QuaffServer do
  @moduledoc """
  The server for quaff. Does everything except for user interaction
  """

  use GenServer

  defmodule QuaffState do
    defstruct players: %{}, xmax: 100, ymax: 100
  end

  defmodule Player do
    defstruct x: 0, y: 0
  end

  def broadcast(state) do
    for pid <- Map.keys(state.players) do
      send pid, { :update, Map.values(state.players) }
    end
  end

  def move(%Player{x: x, y: y}, direction, xmax, ymax) do
    {dx, dy} = case direction do
      :up -> {0, -1}
      :down -> {0, 1}
      :left -> {-1, 0}
      :right -> {1, 0}
    end
    %Player{ x: max(0, min(xmax, x + dx)), y: max(0, min(ymax, y + dy)) }
  end

  def start_link(xmax, ymax) do
    GenServer.start_link(__MODULE__, %QuaffState{xmax: xmax, ymax: ymax}, name: __MODULE__)
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
    new_state = %QuaffState{state | players: Map.put(state.players, from, %Player{x: x, y: y})}
    spawn(QuaffServer, :broadcast, [new_state])
    {:reply, Map.values(new_state.players), new_state}
  end

  def handle_call(:drop, {from, _}, state) do
    new_state = %QuaffState{state | players: Map.delete(state.players, from)}
    spawn(QuaffServer, :broadcast, [new_state])
    {:reply, :ok, new_state}
  end

  def handle_call({:move, direction}, {from, _}, state) do
    new_state = %QuaffState{state | players: Map.update(state.players, from, %Player{}, &(move(&1, direction, state.xmax, state.ymax)))}
    spawn(QuaffServer, :broadcast, [new_state])
    {:reply, :ok, new_state}
  end

  def handle_call(:status, {from, _}, state) do
    {:reply, state, state}
  end
end
