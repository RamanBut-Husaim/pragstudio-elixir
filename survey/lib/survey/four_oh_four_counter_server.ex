defmodule Survey.FourOhFourCounter do

  require Logger

  @name :four_oh_four_counter_server

  def start() do
    Logger.info "starting the 404 counter server..."
    pid = spawn(__MODULE__, :listen_loop, [%{}])
    Process.register(pid, @name)
    pid
  end

  def bump_count(path) when is_binary(path) do
    send @name, {self(), :bump_count, path}

    receive do
      {:response, counter} -> counter
    end
  end

  def get_count(path) when is_binary(path) do
    send @name, {self(), :get_count, path}

    receive do
      {:response, :ok, counter} -> counter
      {:response, :error, message} -> message
    end
  end

  def get_counts() do
    send @name, {self(), :get_counts}

    receive do
      {:response, counts} -> counts
    end
  end

  def listen_loop(state) do
    receive do
      {sender, :bump_count, path} ->
        counter = Map.get(state, path, 0)
        new_state = Map.put(state, path, counter + 1)
        Logger.debug "incrementing count for `#{path}` with value `#{counter}`"
        send sender, {:response, counter + 1}
        listen_loop(new_state)
      {sender, :get_count, path} ->
        case Map.get(state, path) do
          nil ->
            Logger.debug "there is no count saved for `#{path}`"
            send sender, {:response, :error, "no path specified"}
          val ->
            Logger.debug "the value for the `#{path}` is `#{val}`"
            send sender, {:response, :ok, val}
        end
        listen_loop(state)
      {sender, :get_counts} ->
        Logger.debug "returning the whole state"
        send sender, {:response, state}
        listen_loop(state)
      unexpected ->
        Logger.info "unexpected messaged: #{inspect unexpected}"
        listen_loop(state)
    end
  end
end