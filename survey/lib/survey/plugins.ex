defmodule Survey.Plugins do
  require Logger

  @moduledoc """
  Plugins.
  """

  def track(%{status: 404, path: path} = conv) do
    Logger.warn "#{path} is on the loose!"
    conv
  end

  def track(conv), do: conv

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    new_path = "/#{thing}/#{id}"
    Logger.info "rewriting '#{conv.path}' into '#{new_path}'"
    %{ conv | path: new_path }
  end

  def rewrite_path_captures(conv, nil), do: conv

  def log(conv), do: IO.inspect(conv)
end