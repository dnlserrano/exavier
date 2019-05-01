defmodule Exavier.Mutators.AOR1 do
  @mutations %{
    :+ => :-,
    :- => :+,
    :* => :/,
    :/ => :*,
    :rem => :*
  }

  def operators, do: Map.keys(@mutations)

  def mutate(operator) do
    @mutations[operator]
  end
end
