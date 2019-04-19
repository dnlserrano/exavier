defmodule Exavier do
  @moduledoc """
  Documentation for Exavier.
  """

  alias Exavier.Mutator
  alias Exavier.Mutation

  def redefine(file) do
    quoted =
      file
      |> File.read!()
      |> Code.string_to_quoted!()

    {mutated_ast, original, mutation} = mutate(quoted)

    Code.compile_quoted(mutated_ast)

    %Mutation{
      original: original,
      mutation: mutation
    }
  end

  def mutate({:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, do_block]}) do
    {mutated_ast, original, mutation} = do_mutate(do_block)
    {{:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, mutated_ast]}, original, mutation}
  end

  def do_mutate([do: do_block_body]) do
    {mutated_ast, original, mutation} = mutate_all(do_block_body)
    {[do: mutated_ast], original, mutation}
  end

  def mutate_all({:def, _metadata, _function_hdr_body} = function_def) do
    mutate_all({:__block__, [], [function_def]})
  end

  def mutate_all({:__block__, metadata, [def_to_mutate | other_defs]}) do
    {mutated_ast, original, mutation} = mutate_fdef(def_to_mutate)
    {{:__block__, metadata, [mutated_ast | other_defs]}, original, mutation}
  end

  defp mutate_fdef({type, meta, [hdr | [[do: fdef = original]]]}) when type in [:def, :defp] do
    mutation = Mutator.mutate(fdef)
    {{type, meta, [hdr | [[do: mutation]]]}, original, mutation}
  end

  defp mutate_fdef(any), do: {any, any, nil}
end
