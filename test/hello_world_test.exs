defmodule HelloWorldTest do
  use ExUnit.Case, async: true

  @subject HelloWorld

  test "when 2" do
    assert @subject.even?(2) == true
  end

  test "when infinity" do
    assert @subject.even?(:infinity) == nil
  end

  test "when special1" do
    assert @subject.special?(:special) == :yes
  end

  test "when special2" do
    assert @subject.special?(:not_special) == :no
  end
end
