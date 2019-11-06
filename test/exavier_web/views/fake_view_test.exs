defmodule ExavierWeb.FakeViewTest do
    use ExUnit.Case, async: true

    @subject ExavierWeb.FakeView

    test "add test" do
      assert @subject.pow(2, 3) == 8
    end
end
