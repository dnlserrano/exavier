defmodule Exavier.Mutators.ConditionalsBoundary do
  @moduledoc """
  Mutates conditional operators to change their boundary..

  Conditionals are replaced according to the table below.

  | Original | Mutation |
  |----------|----------|
  | <        | <=       |
  | <=       | <        |
  | >        | >=       |
  | >=       | >        |

  For example:

      a < b

  will be mutated into

      a <= b
  """

  @behaviour Exavier.Mutators.Mutator

  @mutations %{
    :< => :<=,
    :<= => :<,
    :> => :>=,
    :>= => :>,
  }

  @impl Exavier.Mutators.Mutator
  def operators, do: Map.keys(@mutations)

  @impl Exavier.Mutators.Mutator
  def mutate({operator, meta, args}, lines_to_mutate) do
    mutated_operator = mutate_operator(operator, args)
    do_mutate({mutated_operator, meta, args}, lines_to_mutate)
  end

  defp mutate_operator(:-, args) when length(args) == 1, do: :-

  defp mutate_operator(operator, _args), do: @mutations[operator]

  defp do_mutate({nil, _, _}, _), do: :skip

  defp do_mutate({mutated_op, meta, args}, lines_to_mutate) do
    {_, mutated_args} = Exavier.mutate_all(args, __MODULE__, lines_to_mutate)
    {mutated_op, meta, mutated_args}
  end
end
