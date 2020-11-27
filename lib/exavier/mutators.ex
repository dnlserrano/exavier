defmodule Exavier.Mutators do
  @mutators [
    __MODULE__.AOR1,
    __MODULE__.AOR2,
    __MODULE__.AOR3,
    __MODULE__.AOR4,
    __MODULE__.ROR1,
    __MODULE__.ROR2,
    __MODULE__.ROR4,
    __MODULE__.IfTrue,
    __MODULE__.NegateConditionals,
    __MODULE__.ConditionalsBoundary
  ]

  def operators do
    mutators()
    |> Enum.flat_map(fn mutator ->
      mutator.operators()
    end)
    |> Enum.uniq()
  end

  def mutators do
    custom_mutators = Exavier.Config.get(:custom_mutators, [])

    unless is_list(custom_mutators) do
      raise "The `:custom_mutators` key in `.exavier.exs` must be a list."
    end

    @mutators ++ custom_mutators
  end
end
