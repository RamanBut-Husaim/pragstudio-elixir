defmodule Survey.Supervisor do
  use Supervisor

  require Logger

  @name __MODULE__

  def start_link() do
    Logger.info "starting THE supervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      Survey.KickStarter,
      Survey.ServicesSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end