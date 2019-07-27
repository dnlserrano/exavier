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

  test "when EXAVIER_DEBUG=1 timeout defaults to infinity" do
    System.put_env("EXAVIER_DEBUG", "1")
    on_exit(self(), fn -> System.delete_env("EXAVIER_DEBUG") end)

    assert @subject.timeout(:anything) == :infinity
  end

  test "when EXAVIER_DEBUG=true timeout defaults to infinity" do
    System.put_env("EXAVIER_DEBUG", "true")
    on_exit(self(), fn -> System.delete_env("EXAVIER_DEBUG") end)

    assert @subject.timeout(:anything) == :infinity
  end

  test "when getting timeout for running whole mutation testing" do
    assert @subject.timeout(:mutate_everything) == 60_000
  end

  test "when getting timeout for when mutating a module" do
    assert @subject.timeout(:mutate_module) == 5000
  end

  test "when getting timeout for when reporting" do
    assert @subject.timeout(:report) == 1000
  end

  test "when getting timeout for unknown action uses default timeout" do
    assert @subject.timeout(:unknown) == 5000
  end
end
