defmodule Survey.Handler do
  @moduledoc """
  Handles HTTP requests.
  """

  @pages_path Path.expand("pages", File.cwd!)

  import Survey.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Survey.Parser, only: [parse: 1]
  import Survey.FileHandler, only: [handle_file: 2]

  alias Survey.Conv
  alias Survey.BearController

  @doc """
  Transforms the request into a response.
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def emojify(%Conv{} = conv), do: conv

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{method: "GET", path: "/wildlife"} = conv) do
    %Conv{conv | path: "/wildthings"}
    |> route
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %Conv{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Survey.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{} = conv) do
    %Conv{ conv | status: 404, resp_body: "No #{conv.path} here!" }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_headers["Content-Type"]}\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end