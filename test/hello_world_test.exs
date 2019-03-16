defmodule HelloWorldTest do
  @subject HelloWorld

  test "when 0" do
    @subject.zero?(0) == true
  end
end
