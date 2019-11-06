defmodule Exavier.Mutators.ROR4 do
  @behaviour Exavier.Mutators.Mutator

  @mutations %{
    :< => :==,
    :<= => :==,
    :> => :==,
    :>= => :==,
    :== => :>=,
    :!= => :>=
  }

  @impl Exavier.Mutators.Mutator
  def operators, do: Map.keys(@mutations)

  @impl Exavier.Mutators.Mutator
  def mutate({operator, meta, args}, lines_to_mutate) do
    mutated_operator = @mutations[operator]
    do_mutate({mutated_operator, meta, args}, lines_to_mutate)
  end

  defp do_mutate({nil, _, _}, _), do: :skip

  defp do_mutate({mutated_op, meta, args}, lines_to_mutate) do
    {_, mutated_args} = Exavier.mutate_all(args, __MODULE__, lines_to_mutate)
    {mutated_op, meta, mutated_args}
  end
end
