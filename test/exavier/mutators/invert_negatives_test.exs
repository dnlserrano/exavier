defmodule Exavier.Mutators.InvertNegativesTest do
  use ExUnit.Case, async: true

  @subject Exavier.Mutators.InvertNegatives

  test "mutates unary negative operator" do
    assert @subject.mutate({:-, [], [5]}, 1) == 5
  end

  test "skip if operator is used for subtraction" do
    assert @subject.mutate({:-, [line: 2], [1, 2]}, 0) == :skip
  end
end
