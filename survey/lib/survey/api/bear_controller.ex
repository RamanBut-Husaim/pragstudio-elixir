defmodule Survey.Api.BearController do
  alias Survey.Conv

  def index(conv) do
    json =
      Survey.Wildthings.list_bears()
      |> Poison.encode!

    conv = put_resp_content_type(conv, "application/json")

    %Conv{conv | status: 200, resp_body: json}
  end

  def create(conv, %{"type" => type, "name" => name}) do
    %Conv{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}!" }
  end

  defp put_resp_content_type(conv, content_type) do
    new_response_headers = Map.put(conv.resp_headers, "Content-Type", content_type)

    %Conv{conv | resp_headers: new_response_headers}
  end
end