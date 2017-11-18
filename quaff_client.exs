if Node.connect(:"server@thinkingpad") do
  # :application.start(:cecho)
  Termbox.init()
  pid = spawn(Quaff.Client, :runclient, [])
  ref = Process.monitor(pid)
  receive do
    {:DOWN, ^ref, _, _, _} -> Termbox.shutdown()
  end
else
  IO.puts("could not connect to server")
end
