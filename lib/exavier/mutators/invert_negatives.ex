defmodule Exavier.Mutators.InvertNegatives do
  @moduledoc """
  The invert negatives mutator inverts negation of integer and floating point numbers.

  For example:

      def negate(n) do
        -n
      end

  will be mutated into

      def negate(n) do
        n
      end
  """

  @behaviour Exavier.Mutators.Mutator

  @operator :-

  @impl Exavier.Mutators.Mutator
  def operators, do: [@operator]

  @impl Exavier.Mutators.Mutator
  def mutate({@operator, _meta, [n]}, _) do
    n
  end

  @impl Exavier.Mutators.Mutator
  def mutate({_, _, _}, _), do: :skip
end
