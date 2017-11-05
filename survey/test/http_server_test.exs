defmodule HttpServerTest do
  use ExUnit.Case, async: true

  alias Survey.HttpServer

  @server_port 4000

  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [@server_port])

    # Spawn the client processes
    url = "http://localhost:#{@server_port}/wildthings"

    1..5
    |> Enum.map(fn(_) -> Task.async(fn -> HTTPoison.get(url) end) end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_successful_response/1)
  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"
  end
end