Code.require_file("../lib/termbox.ex")
defmodule Looper do
  def loop do
    receive do
      {:keyboard, _, _, _, ch, _, _, _, _} ->
        if ch == ?q do
          :ok
        else
          Termbox.change_cell(20, 20, ch, 0, 0)
          Termbox.present()
          loop()
        end
    end
  end
end

Termbox.init()
Termbox.change_cell(20, 20, ?o, 0, 0)

Termbox.present()
{:ok, key} = Termbox.subscribe(self())
Looper.loop
Termbox.unsubscribe(key)
Termbox.shutdown()
