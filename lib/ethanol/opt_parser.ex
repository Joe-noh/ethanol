defmodule OptParser do
  @moduledoc """
  This module provides the feature that parses command line arguments.
  """

  defstruct pattern: "",
            regexp?: false,
            glob: ""

  @doc """
  parses given options and return a struct.

  * `-p` - regard search pattern as plain text

  * `-r` - regard search pattern as regular expression

  * `-e` - an alias of `-r`
  """
  def parse(args) do
    case OptionParser.parse(args, parser_option) do
      {opts, [glob], []} ->
        do_parse(opts, glob)
      _ ->
        {:error, :invalid_option}
    end
  end

  defp do_parse(pattern_option, glob) do
    case pattern_option do
      [plain: pattern] ->
        {:ok, %__MODULE__{pattern: pattern, regexp?: false, glob: glob}}
      [regexp: pattern] ->
        {:ok, %__MODULE__{pattern: pattern, regexp?: true,  glob: glob}}
      _other ->
        {:error, :pattern_missing}
    end
  end

  defp parser_option do
    [
      aliases: [
        p:     :plain,
        e:     :regexp,
        r:     :regexp,
        regex: :regexp
      ],
      strict: [
        plain:  :string,
        regexp: :string
      ]
    ]
  end
end
