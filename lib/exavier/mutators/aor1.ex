defmodule Exavier.Mutators.AOR1 do
  @addition :+
  @subtraction :-
  @multiplication :*
  @division :/
  @remainder :rem

  @mutations %{
    @addition => @subtraction,
    @subtraction => @addition,
    @multiplication => @division,
    @division => @multiplication,
    @remainder => @multiplication
  }

  def operators, do: Map.keys(@mutations)

  def mutate(operator) do
    @mutations[operator]
  end
end
