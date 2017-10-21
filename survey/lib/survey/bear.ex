defmodule Survey.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def is_grizzly(bear), do: bear.type == "Grizzly"

  def order_asc_by_name(bear1, bear2), do: bear1.name <= bear2.name
end