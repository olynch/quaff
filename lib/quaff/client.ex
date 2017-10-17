defmodule Quaff.Client do
  @moduledoc """
  The client for quaff. Handles keyboard input and ncurses output
  """

  alias Quaff.Player, as: Player
  
  def runclient do
    :cecho.cbreak()
    :cecho.noecho()
    :cecho.refresh()
    :cecho.curs_set(0)
    spawn_link(__MODULE__, :keyboard_events, [self()])
    players = GenServer.call({Server, :server@thinkingpad}, {:init, 5, 5})
    clientloop(players)
  end

  def keyboard_events(pid) do
    c = :cecho.getch()
    send pid, { :pressed_key, c }
    keyboard_events(pid)
  end

  def clientloop(players) do
    :cecho.erase()
    for %Player{x: x, y: y} <- players do
      :cecho.mvaddch(y, x, ?@)
    end
    :cecho.refresh()
    receive do
      { :pressed_key, c} ->
        cond do
          c in [?h, ?j, ?k, ?l] ->
            dir = case c do
              ?h -> :left
              ?j -> :down
              ?k -> :up
              ?l -> :right
            end
            GenServer.call({Server, :server@thinkingpad}, {:move, dir})
            clientloop(players)
          c == ?q ->
            GenServer.call({Server, :server@thinkingpad}, :drop)
            :ok
          true ->
            clientloop(players)
        end
      { :update, new_players } -> clientloop(new_players)
    end
  end
end
