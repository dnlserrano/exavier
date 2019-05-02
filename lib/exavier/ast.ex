defmodule Exavier.AST do
  def file_to_quoted(file) do
    quoted =
      file
      |> File.read!()
      |> Code.string_to_quoted!()

    {:defmodule, _mod_meta, [{:__aliases__, _alias_meta, [module_name]}, do_block]} = quoted

    {:"Elixir.#{module_name}", quoted}
  end

  def mutation_operators({:defmodule, _mod_meta, [{:__aliases__, _alias_meta, [_module_name]}, do_block]}) do
    find_mutations(do_block)
  end

  defp find_mutations([{_construct, construct_body} | rest]) do
    find_mutations(construct_body) ++ find_mutations(rest)
  end

  defp find_mutations({operator, meta, args}) do
    save_if_may_be_mutated(operator, meta) ++ find_mutations(args)
  end

  defp find_mutations([head | rest]) do
    find_mutations(head) ++ find_mutations(rest)
  end

  defp find_mutations(_), do: []

  defp save_if_may_be_mutated(operator, meta) do
    case Enum.member?(operators_to_save(), operator) do
      true -> [{operator, meta}]
      _ -> []
    end
  end

  defp operators_to_save() do
    Exavier.Mutators.operators()
  end
end
