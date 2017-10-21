defmodule Survey.Parser do

  alias Survey.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  defp parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim
    |> URI.decode_query
  end

  defp parse_params(_, _), do: %{}

  defp parse_headers(headers_lines), do: parse_headers(%{}, headers_lines)

  defp parse_headers(headers, []), do: headers

  defp parse_headers(headers, [header | other]) do
    [key, value] = String.split(header, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(headers, other)
  end
end