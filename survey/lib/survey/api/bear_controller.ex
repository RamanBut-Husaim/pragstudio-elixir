defmodule Survey.Api.BearController do
  alias Survey.Conv

  def index(conv) do
    json =
      Survey.Wildthings.list_bears()
      |> Poison.encode!

    %Conv{conv | status: 200, resp_content_type: "application/json", resp_body: json}
  end
end