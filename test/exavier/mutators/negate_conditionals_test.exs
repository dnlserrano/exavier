defmodule Exavier.Mutators.NegateConditionalsTest do
  use ExUnit.Case, async: true

  @subject Exavier.Mutators.NegateConditionals

  @mutations [
    %{
      description: "mutates == to !==",
      original_code: {:==, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:!=, [line: 2], [1, 2]}
    },
    %{
      description: "mutates != to ==",
      original_code: {:!=, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:==, [line: 2], [1, 2]}
    },
    %{
      description: "mutates <= to >",
      original_code: {:<=, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:>, [line: 2], [1, 2]}
    },
    %{
      description: "mutates >= to <",
      original_code: {:>=, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:<, [line: 2], [1, 2]}
    },
    %{
      description: "mutates < to >=",
      original_code: {:<, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:>=, [line: 2], [1, 2]}
    },
    %{
      description: "mutates > to <=",
      original_code: {:>, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:<=, [line: 2], [1, 2]}
    },
    %{
      description: "mutates recursively if operator is repeated",
      original_code: {:==, [line: 2], [{:<=, [line: 3], [2, 3]}, false]},
      lines_to_mutate: [2, 3],
      mutated_code: {:!=, [line: 2], [{:>, [line: 3], [2, 3]}, false]}
    }
  ]

  @mutations
  |> Enum.each(fn mutation ->
    @original_code mutation.original_code
    @lines_to_mutate mutation.lines_to_mutate
    @mutated_code mutation.mutated_code
    @description mutation.description

    test @description do
      assert @subject.mutate(@original_code, @lines_to_mutate) ==
               @mutated_code
    end
  end)
end
