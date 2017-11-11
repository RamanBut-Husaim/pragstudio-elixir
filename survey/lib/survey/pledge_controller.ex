defmodule Survey.PledgeController do

  alias Survey.Conv

  import Survey.View

  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    Survey.PledgeServer.create_pledge(name, String.to_integer(amount))

    %Conv{ conv | status: 201, resp_body: "#{name} pledged #{amount}!" }
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = Survey.PledgeServer.recent_pledges()

    render(conv, "recent_pledges.eex", pledges: pledges)
  end

  def new(conv) do
    render(conv, "new_pledge.eex")
  end
end