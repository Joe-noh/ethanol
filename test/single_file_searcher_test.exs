defmodule SingleFileSearcherTest do
  use ExUnit.Case
  alias Ethanol.SingleFileSearcher

  test "find the words in a file" do
    SingleFileSearcher.search("hello", false, "test/sample.txt", self)

    assert_received {:found, {"hi, \e[32mhello\e[0m. how are you?", "test/sample.txt"}}
    assert_received :done
  end
end
