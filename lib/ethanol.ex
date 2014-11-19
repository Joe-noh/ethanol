defmodule Ethanol do
  import Supervisor.Spec
  alias Ethanol.OptParser

  def main(args) do
    opt = OptParser.parse(args)  # is GenServer suitable?

    start(opt.keyword, opt.glob_pattern)
  end

  def start(pattern, glob) do
    children = glob
      |> Path.wildcard
      |> Enum.filter(&File.regular?/1)
      |> Enum.with_index
      |> Enum.map fn ({filepath, index}) ->
        worker(Task,
               [SingleFileSearcher, :search, [pattern, filepath, self]],
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
end
