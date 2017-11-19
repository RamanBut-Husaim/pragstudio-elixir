defmodule PledgeServerTest do
  use ExUnit.Case, async: true

  alias Survey.PledgeServer

  test "caches the 3 most recent pledges and totals their amounts" do
    PledgeServer.start_link(:ok)

    PledgeServer.create_pledge("frodo", 100)
    PledgeServer.create_pledge("sam", 200)
    PledgeServer.create_pledge("mary", 300)
    PledgeServer.create_pledge("pippin", 400)

    expected_pledges = [{"pippin", 400}, {"mary", 300}, {"sam", 200} ]

    assert PledgeServer.recent_pledges() == expected_pledges
    assert PledgeServer.total_pledged() == 900
  end
end