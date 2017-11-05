defmodule Survey.HttpClient do
  def send(port, request) when is_integer(port) and port > 1023 do
    host = 'localhost'

    {:ok, sock} = :gen_tcp.connect(host, port, [:binary, packet: :raw, active: false])

    :ok = :gen_tcp.send(sock, request)

    {:ok, response} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)

    response
  end
end