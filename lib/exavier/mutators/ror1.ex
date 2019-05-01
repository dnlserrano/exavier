defmodule Exavier.Mutators.ROR1 do
  @lt :<
  @lte :<=
  @gt :>
  @gte :>=
  @eq :==
  @neq :!=

  @mutations %{
    @lt => @lte,
    @lte => @lt,
    @gt => @gte,
    @eq => @lt,
    @neq => @lt,
  }

  def operators, do: Map.keys(@mutations)

  def mutate(operator) do
    @mutations[operator]
  end
end
