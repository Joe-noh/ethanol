defmodule SingleFileSearcher do
  def search(pattern, filepath, send_to) do
    regex = Regex.compile! pattern

    filepath
    |> File.stream!
    |> Stream.map(&search_line(&1, regex))
    |> Stream.map(&send_back(&1, filepath, send_to))
    |> Stream.run

    send send_to, :done
  end

  defp search_line(line, regex) do
    line = String.strip(line)
    {line, Regex.scan(regex, line, return: :index) |> List.flatten}
  end

  defp send_back({_, nil}, _, _), do: :ok
  defp send_back({_,  []}, _, _), do: :ok
  defp send_back({line, result}, filepath, send_to) do
    send send_to, {:found, {line, result, filepath}}
  end
end
