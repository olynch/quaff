defmodule MyLogger do
  def logger do
    receive do
      anything -> IO.puts anything
    end
    logger()
  end
end

:global.register_name(:logger, self())
MyLogger.logger
