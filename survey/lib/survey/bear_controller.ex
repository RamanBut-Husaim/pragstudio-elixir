defmodule Survey.BearController do

  alias Survey.Conv
  alias Survey.Wildthings
  alias Survey.Bear

  @templates_path Path.expand("templates", File.cwd!)

  defp render(conv, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %Conv{ conv | status: 200, resp_body: content }
  end

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", [bears: bears])
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", [bear: bear])
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %Conv{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  def delete(conv, %{"id" => _id}) do
    %Conv{ conv | status: 403, resp_body: "Bears must never be deleted!"}
  end
end