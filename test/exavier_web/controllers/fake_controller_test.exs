defmodule ExavierWeb.FakeControllerTest do
  use ExUnit.Case, async: true

  @subject ExavierWeb.FakeController

  test "add test" do
    assert @subject.add(2, 3) == 5
  end
end
