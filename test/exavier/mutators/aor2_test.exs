defmodule Exavier.Mutators.AOR2Test do
  use ExUnit.Case, async: true

  @subject Exavier.Mutators.AOR2

  @mutations [
    %{
      description: "mutates + to *",
      original_code: {:+, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:*, [line: 2], [1, 2]}
    },
    %{
      description: "mutates - to *",
      original_code: {:-, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:*, [line: 2], [1, 2]}
    },
    %{
      description: "mutates * to rem",
      original_code: {:*, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:rem, [line: 2], [1, 2]}
    },
    %{
      description: "mutates / to rem",
      original_code: {:/, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:rem, [line: 2], [1, 2]}
    },
    %{
      description: "mutates rem to /",
      original_code: {:rem, [line: 2], [1, 2]},
      lines_to_mutate: [2],
      mutated_code: {:/, [line: 2], [1, 2]}
    },
    %{
      description: "mutates recursively if operator is repeated",
      original_code: {:rem, [line: 2], [{:rem, [line: 3], [2, 3]}, 2]},
      lines_to_mutate: [2, 3],
      mutated_code: {:/, [line: 2], [{:/, [line: 3], [2, 3]}, 2]}
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
