defmodule Survey.SensorServer do
  require Logger

  use GenServer

  @name :sensor_server
  @refresh_inverval :timer.seconds(5)

  def start() do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def get_sensor_data() do
    GenServer.call @name, :get_sensor_data
  end

  def init(_state) do
    initial_state = run_tasks_to_get_sensor_data()
    schedule_refresh()
    {:ok, initial_state}
  end

  def handle_info(:refresh, _state) do
    Logger.info "refreshing the cache"

    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh()
    {:noreply, new_state}
  end

  def handle_info(unexpected, state) do
    Logger.warn "can't touch this! #{inspect unexpected}"
    {:noreply, state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh, @refresh_inverval)
  end

  defp run_tasks_to_get_sensor_data() do
    Logger.info "running tasts to get sensor data..."

    task = Task.async(fn -> Survey.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Survey.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end