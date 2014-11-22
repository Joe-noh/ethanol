defmodule Ethanol.SingleFileSearcher do
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
    case String.split(line, pattern) do
      [_one] ->
        nil
      list ->
        glue = IO.ANSI.green <> pattern <> IO.ANSI.reset
        Enum.join(list, glue)
    end
  end

  defp search_line(line, regex) do
    if Regex.match?(regex, line) do
      Regex.replace(regex, line, IO.ANSI.green <> "\\0" <> IO.ANSI.reset)
    end
  end

  defp send_back(nil,      _, _), do: :ok
  defp send_back({_, nil}, _, _), do: :ok
  defp send_back({_,  []}, _, _), do: :ok
  defp send_back(colored, filepath, send_to) do
    send send_to, {:found, {colored, filepath}}
  end
end
