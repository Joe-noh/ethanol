defmodule Ethanol do
  import Supervisor.Spec
  alias Ethanol.OptParser
  alias Ethanol.SingleFileSearcher

  def main(args) do
    case OptParser.parse(args) do
      {:ok, opt} ->
        start(opt.pattern, opt.regexp?, opt.glob)
      {:error, code} ->
        process_error(code)
        System.exit(1)
    end
  end

  def start(pattern, regexp?, glob) do
    children = glob
      |> Path.wildcard
      |> Enum.filter(&File.regular?/1)
      |> Enum.with_index
      |> Enum.map fn ({filepath, index}) ->
        worker(Task,
               [SingleFileSearcher, :search, [pattern, regexp?, filepath, self]],
               restart: :transient,
               id: String.to_atom("searcher_#{index}"))
      end

    Supervisor.start_link(children,
                          strategy: :one_for_one)

    loop(Enum.count children)
  end

  defp loop(0), do: exit :normal

  defp loop(num_children) do
    receive do
      {:found, res} ->
        output res
        loop(num_children)
      :done ->
        loop(num_children - 1)
      _ ->
        exit :error
    end
  end

  defp output(search_result) do
    output(search_result, "")
  end

  defp output({_, [], path}, colored) do
    IO.puts(path <> ": " <> colored)
  end

  defp output({line, res = [{index, length} | rest], path}, acc) do
    {head, tail}  = String.split_at(line, index)
    {match, tail} = String.split_at(tail, length)
    acc = acc <> head <> IO.ANSI.green <> match <> IO.ANSI.reset <> tail
    output({tail, rest, path}, acc)
  end

  defp process_error(error) do
    case error do
      _ -> show_usage
    end
  end

  defp show_usage do
    IO.puts """
    $ et -p hoge ./*.exs
    """
  end
end
