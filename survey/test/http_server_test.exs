defmodule HttpServerTest do
  use ExUnit.Case, async: true

  alias Survey.HttpServer

  @server_port 4000

  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [@server_port])

    {:ok, response} = HTTPoison.get "http://localhost:#{@server_port}/wildthings"

    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers"
  end
end