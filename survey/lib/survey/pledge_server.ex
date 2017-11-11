defmodule Survey.PledgeServer do

  require Logger

  @name :pledge_server
  @pledge_endpoint "https://httparrot.herokuapp.com/post"

  def start() do
    Logger.info "starting the pledge server..."
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    send @name, {self(), :create_pledge, name, amount}

    receive do
      {:response, status} ->
        status
    end
  end

  def recent_pledges() do
    send @name, {self(), :recent_pledges}

    receive do
      {:response, pledges} ->
        pledges
    end
  end

  def total_pledged() do
    send @name, {self(), :total_pledged}

    receive do
      {:response, total} ->
        total
    end
  end

  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send sender, {:response, id}
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send sender, {:response, state}
        listen_loop(state)
      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
        send sender, {:response, total}
        listen_loop(state)
      unexpected ->
        Logger.info "unexpected messaged: #{inspect unexpected}"
        listen_loop(state)
    end
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

# alias Survey.PledgeServer

# pid = PledgeServer.start()

# send pid, {:stop, "hammertime"}

# IO.inspect PledgeServer.create_pledge("larry", 10)
# IO.inspect PledgeServer.create_pledge("moe", 20)
# IO.inspect PledgeServer.create_pledge("curly", 30)
# IO.inspect PledgeServer.create_pledge("daisy", 40)
# IO.inspect PledgeServer.create_pledge("grace", 50)

# IO.inspect PledgeServer.recent_pledges()

# IO.inspect PledgeServer.total_pledged()

# IO.inspect Process.info(pid, :messages)