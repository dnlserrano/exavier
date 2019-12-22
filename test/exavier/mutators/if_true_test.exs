defmodule Exavier.Mutators.IfTrueTest do
  use ExUnit.Case, async: true

  @subject Exavier.Mutators.IfTrue

  test "mutates if to unconditional true" do
    assert @subject.mutate({:if, [], [1, 2]}, 0) ==
             {:if, [], [true, 2]}
  end

  test "skip if not if operator" do
    assert @subject.mutate({:+, [line: 2], [1, 2]}, 0) == :skip
  end
end
