defmodule Survey.GenericServer do

  require Logger

  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send pid, {:call, self(), message}

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state, callback_module)
      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)
      unexpected ->
        Logger.info "unexpected messaged: #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end
end

defmodule Survey.FourOhFourCounter do

  require Logger

  alias Survey.GenericServer

  @name :four_oh_four_counter_server

  def start() do
    Logger.info "starting the 404 counter server..."
    GenericServer.start(__MODULE__, %{}, @name)
  end

  def bump_count(path) when is_binary(path) do
    GenericServer.call @name, {:bump_count, path}
  end

  def get_count(path) when is_binary(path) do
    GenericServer.call @name, {:get_count, path}
  end

  def get_counts() do
    GenericServer.call @name, :get_counts
  end

  def reset() do
    GenericServer.cast @name, :reset
  end

  def handle_call({:bump_count, path}, state) do
    counter = Map.get(state, path, 0)
    new_state = Map.put(state, path, counter + 1)
    Logger.debug "incrementing count for `#{path}` with value `#{counter}`"
    {counter + 1, new_state}
  end

  def handle_call({:get_count, path}, state) do
    counter = Map.get(state, path, 0)
    {counter, state}
  end

  def handle_call(:get_counts, state) do
    Logger.debug "returning the whole state"
    {state, state}
  end

  def handle_cast(:reset, _state) do
    Logger.debug "resetting state"
    %{}
  end
end