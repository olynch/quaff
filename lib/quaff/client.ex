defmodule Quaff.Client do
  @moduledoc """
  The client for quaff. Handles keyboard input and ncurses output
  """

  alias Quaff.Player, as: Player
  alias Quaff.QMap, as: QMap
  alias Quaff.QMap.Parser, as: Parser
  
  def runclient do
    # :cecho.cbreak()
    # :cecho.noecho()
    # :cecho.refresh()
    # :cecho.curs_set(0)
    # spawn_link(__MODULE__, :keyboard_events, [self()])
    players = GenServer.call({Quaff.Server, :server@thinkingpad}, {:init, 5, 5})
    qmap = Parser.parse_qmap("test.qmap")
    Termbox.subscribe(self())
    clientloop(players, qmap)
  end

  # def keyboard_events(pid) do
  #   c = :cecho.getch()
  #   send pid, { :pressed_key, c }
  #   keyboard_events(pid)
  # end

  def clientloop(players, qmap) do
    Termbox.clear()
    QMap.disp(qmap, {0,0})
    Termbox.present()
    for %Player{x: x, y: y} <- players do
      Termbox.change_cell(x, y, ?@, 0, 0)
    end
    Termbox.present()
    receive do
      { :keyboard, _, _, _, c, _, _, _, _ } ->
        cond do
          c in [?h, ?j, ?k, ?l] ->
            dir = case c do
              ?h -> :left
              ?j -> :down
              ?k -> :up
              ?l -> :right
            end
            GenServer.call({Quaff.Server, :server@thinkingpad}, {:move, dir})
            clientloop(players, qmap)
          c == ?q ->
            GenServer.call({Quaff.Server, :server@thinkingpad}, :drop)
            :ok
          true ->
            clientloop(players, qmap)
        end
      { :update, new_players } -> clientloop(new_players, qmap)
    end
  end
end
