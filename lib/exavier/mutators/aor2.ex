defmodule Exavier.Mutators.AOR2 do
  @addition :+
  @subtraction :-
  @multiplication :*
  @division :/
  @remainder :rem

  @mutations %{
    @addition => @multiplication,
    @subtraction => @multiplication,
    @multiplication => @remainder,
    @division => @remainder,
    @remainder => @division
  }

  def operators, do: Map.keys(@mutations)

  def mutate(operator) do
    @mutations[operator]
  end
end
