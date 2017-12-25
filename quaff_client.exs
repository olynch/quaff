if Node.connect(:"server@thinkingpad") do
  Termbox.init()
  pid = spawn(Quaff.Client, :runclient, [:"server@thinkingpad"])
  ref = Process.monitor(pid)
  receive do
    {:DOWN, ^ref, _, _, _} -> Termbox.shutdown()
  end
else
  IO.puts("could not connect to server")
end
