defmodule FooBarTest do
  use ExUnit.Case, async: true

  @subject FooBar

  test "when 0, sub 0" do
    assert @subject.sub(0, 0) == 0
  end

  test "when [1, 2, 3], list_sum 6" do
    assert @subject.list_sum([1, 2, 3]) == 6
  end
end
