defmodule Survey.KickStarter do
  use GenServer

  require Logger

  @name __MODULE__

  def start_link(_arg) do
    Logger.info "starting the kickstarter"

    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(_state) do
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    {:ok, server_pid}
  end

  def get_server() do
    GenServer.call @name, :get_server
  end

  def handle_info({:EXIT, pid, reason}, _state) do
    Logger.warn "httpserver process `#{inspect pid}` exited with reason `#{inspect reason}`"
    server_pid = start_server()
    {:noreply, server_pid}
  end

  def handle_call(:get_server, _from, state) do
    {:reply, state, state}
  end

  defp start_server() do
    Logger.info "starting the http server"
    server_pid = spawn_link(Survey.HttpServer, :start, [4000])
    Process.register(server_pid, :http_server)
    server_pid
  end
end