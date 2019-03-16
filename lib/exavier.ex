defmodule Exavier do
  @moduledoc """
  Documentation for Exavier.
  """

  alias Exavier.Mutation

  defmacro mutate([do: do_block_body]) do
    [do: mutate_all(do_block_body)]
  end

  defp mutate_all({:def, _metadata, _function_hdr_body} = function_def) do
    mutate_all({:__block__, [], [function_def]})
  end

  defp mutate_all({:__block__, _metadata, definitions} = do_block) do
    definitions
    |> Enum.map(&(mutate_fdef(&1)))
    |> update_block_definitions(do_block)
  end

  defp mutate_fdef({type, meta, [hdr | [[do: fdef]]]}) when type in [:def, :defp] do
    {type, meta, [hdr | [[do:  Mutation.mutate(fdef)]]]}
  end

  defp mutate_fdef(any), do: any

  defp update_block_definitions(new_definitions, {_block, _metadata, _definitions} = do_block) do
    do_block
    |> put_elem(2, new_definitions)
  end
end
