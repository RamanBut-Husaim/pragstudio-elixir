defmodule Survey.ServicesSupervisor do
  use Supervisor

  require Logger

  @name __MODULE__

  def start_link(_arg) do
    Logger.info "starting the services supervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      Survey.PledgeServer,
      Survey.SensorServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end