defmodule Exavier.Mutators.IfTrue do
  @operator :if

  def operators, do: [@operator]

  def mutate({@operator, meta, [_, body]}, _) do
    {@operator, meta, [true, body]}
  end

  def mutate({_, _, _}, _), do: :skip
end
