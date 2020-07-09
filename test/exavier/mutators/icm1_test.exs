defmodule Exavier.Mutators.ICM1Test do
  use ExUnit.Case, async: true

  @subject Exavier.Mutators.ICM1

  @mutations [
    %{
      description: "mutates true to false",
      original_code: {true, [line: 2], [1, 1]},
      lines_to_mutate: [2],
      mutated_code: {false, [line: 2], [1, 1]}
    },
    %{
      description: "mutates false to true",
      original_code: {false, [line: 2], [1, 1]},
      lines_to_mutate: [2],
      mutated_code: {true, [line: 2], [1, 1]}
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
