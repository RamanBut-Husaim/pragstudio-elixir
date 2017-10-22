defmodule Survey.Plugins do
  @moduledoc """
  Plugins.
  """

  require Logger

  alias Survey.Conv

  def track(%Conv{status: 404, path: path} = conv) do
    Logger.warn "#{path} is on the loose!"
    conv
  end

  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    new_path = "/#{thing}/#{id}"
    Logger.info "rewriting '#{conv.path}' into '#{new_path}'"
    %Conv{ conv | path: new_path }
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect(conv)
    end
    conv
  end
end