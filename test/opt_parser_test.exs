defmodule OptParserTest do
  use ShouldI
  alias Ethanol.OptParser

  with "valid input" do
    should "parse options that contain -p" do
      {:ok, opt} = OptParser.parse(["-p", "search_pattern", "./*.ex"])

      assert opt.pattern == "search_pattern"
      assert opt.regexp? == false
      assert opt.glob    == "./*.ex"
    end

    should "parse options that contain -e" do
      {:ok, opt} = OptParser.parse(["-e", "search_pattern", "./*.ex"])

      assert opt.pattern == "search_pattern"
      assert opt.regexp? == true
      assert opt.glob    == "./*.ex"
    end

    should "parse options that contain -r" do
      {:ok, opt} = OptParser.parse(["-r", "search_pattern", "./*.ex"])

      assert opt.pattern == "search_pattern"
      assert opt.regexp? == true
      assert opt.glob    == "./*.ex"
    end
  end

  with "invalid input" do
    should "return error when input is empty" do
      assert {:error, :invalid_option} == OptParser.parse([])
    end

    should "return error when pattern is missing" do
      assert {:error, :pattern_missing} == OptParser.parse(["./*.exs"])
    end
  end
end

