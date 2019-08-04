defmodule Exavier.Mutators.IfTrue do
  @behaviour Exavier.Mutators.Mutator

  @operator :if

  @impl Exavier.Mutators.Mutator
  def operators, do: [@operator]

  @impl Exavier.Mutators.Mutator
  def mutate({@operator, meta, [_, body]}, _) do
    {@operator, meta, [true, body]}
  end

  @impl Exavier.Mutators.Mutator
  def mutate({_, _, _}, _), do: :skip
end
