defmodule Survey.KickStarter do
  use GenServer

  require Logger

  def start() do
    Logger.info "starting the kickstarter"

    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_state) do
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    {:ok, server_pid}
  end

  def handle_info({:EXIT, pid, reason}, _state) do
    Logger.warn "httpserver process `#{inspect pid}` exited with reason `#{inspect reason}`"
    server_pid = start_server()
    {:noreply, server_pid}
  end

  defp start_server() do
    Logger.info "starting the http server"
    server_pid = spawn_link(Survey.HttpServer, :start, [4000])
    Process.register(server_pid, :http_server)
    server_pid
  end
end