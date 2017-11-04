defmodule Survey.HttpClient do
  def send(port) when is_integer(port) and port > 1023 do
    host = 'localhost'

    {:ok, sock} = :gen_tcp.connect(host, port, [:binary, packet: :raw, active: false])

    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    :ok = :gen_tcp.send(sock, request)
    :ok = :gen_tcp.close(sock)
  end
end