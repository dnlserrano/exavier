defmodule Exavier.Mutators.AOR2 do
  @mutations %{
    :+ => :*,
    :- => :*,
    :* => :rem,
    :/ => :rem,
    :rem => :/
  }

  def operators, do: Map.keys(@mutations)

  def mutate(operator) do
    @mutations[operator]
  end
end
