defmodule Survey do
  use Application

  require Logger

  def start(_type, _args) do
    Logger.info "starting the application..."
    Survey.Supervisor.start_link()
  end
end
