defmodule Ethanol.SingleFileSearcher do
  @dont_send_back {"", nil}

  def search(pattern, regexp?, filepath, send_to) do
    pattern = if regexp? do
      Regex.compile! pattern
    else
      pattern
    end

    filepath
    |> File.stream!
    |> Stream.map(&String.rstrip(&1, ?\n))
    |> Stream.map(&search_line(&1, pattern))
    |> Stream.map(&send_back(&1, filepath, send_to))
    |> Stream.run

    send send_to, :done
  end

  defp search_line(line, pattern) when is_binary(pattern) do
    if String.contains?(line, pattern) do
      len = String.length(pattern)

      {line, search_string(line, pattern)}
    else
      @dont_send_back
    end
  end

  defp search_line(line, regex) do
    {line, Regex.scan(regex, line, return: :index) |> List.flatten}
  end

  defp search_string(line, pattern) do
    line
    |> String.split(pattern)
    |> to_indices(String.length(pattern), [])
  end

  defp to_indices([_last_one], _, acc) do
    Enum.reverse acc
  end

  defp to_indices([head | rest], len, acc) do
    to_indices rest, len, [{String.length(head), len} | acc]
  end

  defp send_back({_, nil}, _, _), do: :ok
  defp send_back({_,  []}, _, _), do: :ok
  defp send_back({line, result}, filepath, send_to) do
    send send_to, {:found, {line, result, filepath}}
  end
end
