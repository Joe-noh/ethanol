defmodule SingleFileSearcherTest do
  use ExUnit.Case

  test "find the words in a file" do
    SingleFileSearcher.search("hello", "test/sample.txt", self)

    assert_received {:found, {"hi, hello. how are you?", [{4, 5}], "test/sample.txt"}}
    assert_received :done
  end
end
