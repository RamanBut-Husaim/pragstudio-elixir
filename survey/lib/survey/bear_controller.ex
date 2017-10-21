defmodule Survey.BearController do

  alias Survey.Conv
  alias Survey.Wildthings
  alias Survey.Bear

  def index(conv) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_grizzly/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)
      |> Enum.map(&create_bear_item/1)
      |> Enum.join

    %Conv{ conv | status: 200, resp_body: "<ul>#{items}</ul>" }
  end

  defp create_bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %Conv{ conv | status: 200, resp_body: "<h1> Bear #{bear.id}: #{bear.name} </h1>" }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %Conv{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end
end