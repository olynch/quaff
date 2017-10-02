defmodule Quaff do
  @moduledoc """
  Documentation for Quaff.
  """
  use Application
  @name :quaff

  @doc """
  Quaff

  """

  defmodule State do
    defstruct x: 0, y: 0
  end

  def start(_type, _args) do
    pid = spawn_link(Quaff, :move_at, [])
    :global.register_name(@name, pid)
    { :ok, pid }
  end

  def keyboard_events(pid) do
    c = :cecho.getch()
    send pid, { :pressed_key, c }
    keyboard_events(pid)
  end

  def move_at do
    :cecho.cbreak()
    :cecho.noecho()
    :cecho.refresh()
    :cecho.curs_set(0)
    spawn_link(Quaff, :keyboard_events, [self()])
    ctrl(%State{})
  end

  def ctrl(qs) do
    :cecho.erase()
    :cecho.mvaddch(qs.y, qs.x, ?@)
    :cecho.refresh()
    receive do
      { :pressed_key, c } ->
        case c do
          ?q -> :ok
          ?h -> ctrl(%State{ qs | x: max(0, qs.x - 1)})
          ?j -> ctrl(%State{ qs | y: qs.y + 1})
          ?k -> ctrl(%State{ qs | y: max(0, qs.y - 1)})
          ?l -> ctrl(%State{ qs | x: qs.x + 1})
          _ -> ctrl(qs)
        end
      _ -> ctrl(qs)
    end
  end
end
