defmodule Survey.FourOhFourCounter do

  require Logger

  use GenServer

  @name :four_oh_four_counter_server

  def start() do
    Logger.info "starting the 404 counter server..."
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def bump_count(path) when is_binary(path) do
    GenServer.call @name, {:bump_count, path}
  end

  def get_count(path) when is_binary(path) do
    GenServer.call @name, {:get_count, path}
  end

  def get_counts() do
    GenServer.call @name, :get_counts
  end

  def reset() do
    GenServer.cast @name, :reset
  end

  def handle_call({:bump_count, path}, _from, state) do
    counter = Map.get(state, path, 0)
    new_state = Map.put(state, path, counter + 1)
    Logger.debug "incrementing count for `#{path}` with value `#{counter}`"
    {:reply, counter + 1, new_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    counter = Map.get(state, path, 0)
    {:reply, counter, state}
  end

  def handle_call(:get_counts, _from, state) do
    Logger.debug "returning the whole state"
    {:reply, state, state}
  end

  def handle_cast(:reset, _state) do
    Logger.debug "resetting state"
    {:noreply, %{}}
  end
end