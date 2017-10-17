if Node.connect(:"server@thinkingpad") do
  :application.start(:cecho)
  QuaffClient.runclient()
  :application.stop(:cecho)
else
  IO.puts("could not connect to server")
end
