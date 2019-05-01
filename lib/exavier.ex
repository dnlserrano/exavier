defmodule Exavier do
  @moduledoc """
  Documentation for Exavier.
  """

  def redefine(quoted, mutator) do
    mutated =
      quoted
      |> mutate_all(mutator)

    mutated
    |> Code.compile_quoted()
  end

  defp mutate_all({:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, do_block]}, mutator) do
    mutated_do_block = mutate_all(do_block, mutator)
    {:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, mutated_do_block]}
  end

  defp mutate_all([{construct, construct_body} | rest], mutator) do
    mutated_construct_body = mutate_all(construct_body, mutator)
    mutated_rest = mutate_all(rest, mutator)

    [{construct, mutated_construct_body} | mutated_rest]
  end

  defp mutate_all({operator, meta, args}, mutator) do
    mutated_args = mutate_all(args, mutator)
    mutated_operator =
      case apply(mutator, :mutate, [operator]) do
        nil -> operator
        mutation -> mutation
      end

    {mutated_operator, meta, mutated_args}
  end

  defp mutate_all([head | rest], mutator) do
    [mutate_all(head, mutator) | mutate_all(rest, mutator)]
  end

  defp mutate_all(any, _mutator), do: any
end
