defmodule FooBarTest do
  use ExUnit.Case, async: true

  @subject FooBar

  test "when 0, 0" do
    assert @subject.sub(0, 0) == 0
  end
end
