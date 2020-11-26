defmodule Exavier.Mutators.AOR4 do
  @moduledoc """
  Mutates arithmetic operators into another operation..

  Conditionals are replaced according to the table below.

  | Original | Mutation |
  |----------|----------|
  | +        | rem/2    |
  | -        | rem/2    |
  | *        | -        |
  | /        | -        |
  | rem/2    | -        |

  For example:

      a = b + 5

  will be mutated into

      a = rem(b, 5)
  """

  @behaviour Exavier.Mutators.Mutator

  @mutations %{
    :+ => :rem,
    :- => :rem,
    :* => :-,
    :/ => :-,
    :rem => :-
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
