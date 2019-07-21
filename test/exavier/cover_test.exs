defmodule Exavier.CoverTest do
  use ExUnit.Case, async: true

  @subject Exavier.Cover

  @tests_to_run [
    %{test_file: "test/foo_bar_test.exs", module: FooBar, lines_covered: [2]},
    %{test_file: "test/hello_world_test.exs", module: HelloWorld, lines_covered: [3, 6]}
  ]

  @tests_to_run
  |> Enum.each(fn test_to_run ->
    @test_file test_to_run.test_file
    @module test_to_run.module
    @lines_covered test_to_run.lines_covered

    test "returns expected covered lines #{@lines_covered} for #{@module} considering #{@test_file}" do
      assert @subject.lines_to_mutate(@module, @test_file) == @lines_covered
    end
  end)
end
