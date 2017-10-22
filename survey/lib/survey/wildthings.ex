defmodule Survey.Wildthings do
  require Logger

  alias Survey.Bear

  @db_path Path.expand("db/bears.json", File.cwd!)

  def list_bears do
    read_db_content()
    |> Poison.decode!(as: %{"bears" => [%Bear{}]})
    |> Map.get("bears")
  end

  defp read_db_content() do
    file_content = File.read(@db_path)

    case file_content do
      {:ok, content} -> content
      {:error, reason} -> 
        Logger.warn "error reading file '#{@db_path}' - #{reason}"
        "[]"
    end
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn(b) -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id
    |> String.to_integer
    |> get_bear()
  end
end