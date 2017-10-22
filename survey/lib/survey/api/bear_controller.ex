defmodule Survey.Api.BearController do
  alias Survey.Conv

  def index(conv) do
    json =
      Survey.Wildthings.list_bears()
      |> Poison.encode!

    new_response_headers = Map.put(conv.resp_headers, "Content-Type", "application/json")

    %Conv{conv | status: 200, resp_headers: new_response_headers, resp_body: json}
  end
end