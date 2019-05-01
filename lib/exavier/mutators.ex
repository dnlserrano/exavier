defmodule Exavier.Mutators do
  @mutators [
    __MODULE__.AOR1,
    __MODULE__.AOR2,
    __MODULE__.ROR1
  ]

  def operators do
    @mutators
    |> Enum.flat_map(fn mutator ->
      mutator.operators()
    end)
    |> Enum.uniq()
  end

  def mutators_for(_operator), do: @mutators
end
