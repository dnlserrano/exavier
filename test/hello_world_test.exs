defmodule HelloWorldTest do
  use ExUnit.Case, async: true

  @subject HelloWorld

  test "when 0" do
    assert @subject.zero?(0) == true
  end
end
