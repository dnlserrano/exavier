defmodule Exavier.Mutators.ROR1 do
  @mutations %{
    :< => :<=,
    :<= => :<,
    :> => :<,
    :>= => :<,
    :== => :<,
    :!= => :<,
  }

  def operators, do: Map.keys(@mutations)

  def mutate(operator) do
    @mutations[operator]
  end
end
