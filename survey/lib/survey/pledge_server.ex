defmodule Survey.PledgeServer do

  require Logger

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  @name :pledge_server
  @pledge_endpoint "https://httparrot.herokuapp.com/post"

  def start() do
    Logger.info "starting the pledge server..."
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges() do
    GenServer.call @name, :recent_pledges
  end

  def total_pledged() do
    GenServer.call @name, :total_pledged
  end

  def clear() do
    GenServer.cast @name, :clear
  end

  def set_cache_size(size) when is_integer(size) do
    GenServer.cast @name, {:set_cache_dize, size}
  end

  # Server Callback

  def init(state) do
    Logger.info "initializing the pledge server..."
    pledges = fetch_recent_pledges_from_service()
    new_state = %State{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %State{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %State{ state | pledges: []}}
  end

  def handle_cast({:set_cache_dize, size}, state) do
    resized_cache = Enum.take(state.pledges, size)
    new_state = %State{state | cache_size: size, pledges: resized_cache}
    {:noreply, new_state}
  end

  def handle_info(message, state) do
    Logger.warn "can't touch this - #{inspect message}"
    {:noreply, state}
  end

  defp fetch_recent_pledges_from_service() do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example return value:
    [ {"wilma", 15}, {"fred", 25} ]
  end

  defp send_pledge(name, amount) do
    # CODE GOES HERE TO SEND TO EXTERNAL SERVER
    pledge = ~s({"name" : #{name}, "amount": #{amount}})
    headers = [{"Content-Type", "application/json"}]
    case HTTPoison.post @pledge_endpoint, pledge, headers do
      {:ok, _response} ->
        Logger.debug "the pledge creation has been performed successfully"
        {:ok, "pledge-#{:rand.uniform(1000)}"}
      {:error, reason} ->
        Logger.debug "the pledge creation failed with reasong #{reason}"
        {:error, reason}
    end
  end
end