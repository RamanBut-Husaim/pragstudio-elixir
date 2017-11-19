defmodule Survey.SensorServer do
  require Logger

  use GenServer

  @name :sensor_server

  defmodule State do
    defstruct sensor_data: %{}, refresh_interval: :timer.minutes(5)
  end

  def start_link(_arg) do
    Logger.info "starting the sensor server..."
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def get_sensor_data() do
    GenServer.call @name, :get_sensor_data
  end

  def set_refresh_interval(time_in_ms) when is_integer(time_in_ms) and time_in_ms > 0 do
    GenServer.cast @name, {:set_refresh_interval, time_in_ms}
  end

  def init(state) do
    sensor_data = run_tasks_to_get_sensor_data()
    initial_state = %State{state | sensor_data: sensor_data}
    schedule_refresh(initial_state)
    {:ok, initial_state}
  end

  def handle_info(:refresh, state) do
    Logger.info "refreshing the cache"

    sensor_data = run_tasks_to_get_sensor_data()
    new_state = %State{ state | sensor_data: sensor_data}
    schedule_refresh(new_state)
    {:noreply, new_state}
  end

  def handle_info(unexpected, state) do
    Logger.warn "can't touch this! #{inspect unexpected}"
    {:noreply, state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:set_refresh_interval, time_in_ms}, state) do
    new_state = %State{state | refresh_interval: time_in_ms}
    {:noreply, new_state}
  end

  defp schedule_refresh(state) do
    Process.send_after(self(), :refresh, state.refresh_interval)
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