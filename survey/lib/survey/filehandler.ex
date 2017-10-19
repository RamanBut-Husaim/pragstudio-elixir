defmodule Survey.FileHandler do

  alias Survey.Conv

  def handle_file({:ok, content}, %Conv{} = conv) do
    %Conv{ conv | status: 200, resp_body: content }
  end

  def handle_file({:error, :enoent}, %Conv{} = conv) do
    %Conv{ conv | status: 404, resp_body: "File not found" }
  end

  def handle_file({:error, reason}, %Conv{} = conv) do
    %Conv{ conv | status: 500, resp_body: "File error: #{reason}" }
  end
end