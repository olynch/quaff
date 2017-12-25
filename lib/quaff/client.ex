defmodule Quaff.Client do
  @moduledoc """
  The client for quaff. Handles keyboard input and ncurses output
  """

  alias Quaff.Player, as: Player
  alias Quaff.QMap, as: QMap
  alias Quaff.Tile, as: Tile
  alias Quaff.Update, as: Update

  defmodule State do
    defstruct serveraddr: nil, players: [], map: QMap.new([[%Tile{}]], 1, 1)
  end

  def update_state(state, update) do
    case update.map do
      {:ok, new_map} ->
        %State{ state | map: new_map, players: update.players }
      _ ->
        %State{ state | players: update.players }
    end
  end
  
  def runclient(serveraddr) do
    %Update{players: players, map: {:ok, map}} = GenServer.call({Quaff.Server, serveraddr}, {:init, 5, 5})
    Termbox.subscribe(self())
    clientloop(%State{ serveraddr: serveraddr, players: players, map: map })
  end

  def clientloop(state) do
    curhp = Map.fetch!(state.players, self()).hp
    if curhp <= 0 do
      GenServer.call({Quaff.Server, state.serveraddr}, :drop)
      :ok
    else
      Termbox.clear()
      for {c,i} <- Enum.zip(Enum.concat('HP: ', Integer.to_charlist(curhp)), 1..100) do
        Termbox.change_cell(i, 0, c, 0, 0)
      end
      QMap.disp(state.map, {1,0})
      for p <- Map.values(state.players) do
        Termbox.change_cell(p.x, p.y + 1, ?@, 0, 0)
      end
      Termbox.present()
      receive do
        { :keyboard, _, _, _, c, _, _, _, _ } ->
          cond do
            c in [?h, ?j, ?k, ?l, ?y, ?u, ?b, ?n] ->
              dir = case c do
                ?h -> :left
                ?j -> :down
                ?k -> :up
                ?l -> :right
                ?y -> :ul
                ?u -> :ur
                ?b -> :dl
                ?n -> :dr
              end
              GenServer.call({Quaff.Server, state.serveraddr}, {:move, dir})
              clientloop(state)
            c == ?q ->
              GenServer.call({Quaff.Server, state.serveraddr}, :drop)
              :ok
            true ->
              clientloop(state)
          end
        { :update, update } -> clientloop(update_state(state, update))
      end
    end
  end
end
