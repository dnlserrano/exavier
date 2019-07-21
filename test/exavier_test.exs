defmodule ExavierTest do
  use ExUnit.Case, async: true

  @subject Exavier

  test "returns quoted code from given file" do
    {:defmodule, _meta, [{:__aliases__, [line: 1], [module]}, _]} =
      @subject.file_to_quoted("lib/foo_bar.ex")

    assert module == :FooBar
  end

  test "translate test module to module" do
    assert @subject.test_module_to_module(ExavierTest) == Exavier
  end

  test "translate test file to module" do
    assert @subject.test_file_to_module("test/exavier_test.exs") == Exavier
  end
end
