defmodule Exavier do
  @moduledoc """
  Documentation for Exavier.
  """

  def file_to_quoted(file) do
    quoted =
      file
      |> File.read!()
      |> Code.string_to_quoted!()

    {:defmodule, _mod_meta, [{:__aliases__, _alias_meta, [module_name]}, _do_block]} = quoted

    atom_module = string_to_elixir_module(module_name)

    {atom_module, quoted}
  end

  def test_module_to_module(test_module) do
    test_module
    |> to_string()
    |> String.trim_trailing("Test")
    |> Macro.camelize()
    |> string_to_elixir_module()
  end

  def test_file_to_module(test_file) do
    test_file
    |> Path.basename()
    |> String.trim_trailing("_test.exs")
    |> String.trim_trailing("_test.ex")
    |> Macro.camelize()
    |> string_to_elixir_module()
  end

  def quoted_to_string([do: {:__block__, [], args}], lines) do
    quoted_to_string(args, lines)
  end

  def quoted_to_string([do: do_block], lines) do
    quoted_to_string(do_block, lines)
  end

  def quoted_to_string({_op, [line: line], args} = quoted, lines) do
    case Enum.member?(lines, line) do
      true -> Macro.to_string(quoted)
      _ -> quoted_to_string(args, lines)
    end
  end

  def quoted_to_string(args, lines) when is_list(args) do
    args
    |> Enum.map(& quoted_to_string(&1, lines))
    |> Enum.reject(& is_nil(&1))
    |> List.flatten()
    |> Enum.at(0)
  end

  def quoted_to_string(_anything, _lines), do: nil

  def redefine(original, mutator, lines_to_mutate) do
    mutated =
      original
      |> mutate_all(mutator, lines_to_mutate)

    mutated
    |> Code.compile_quoted()

    result =
      case original != mutated do
        true -> :mutated
        _ -> :original
      end

    {result, original, mutated}
  end

  def unrequire_file(file) do
    to_unrequire =
      Code.required_files()
      |> Enum.find(fn required_file ->
        String.contains?(required_file, file)
      end)

    Code.unrequire_files([to_unrequire])
  end

  defp string_to_elixir_module("Elixir." <> _rest = module_name) do
    String.to_existing_atom(module_name)
  end

  defp string_to_elixir_module(module_name) do
    String.to_existing_atom("Elixir.#{module_name}")
  end

  def mutate_all({:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, do_block]}, mutator, lines_to_mutate) do
    mutated_do_block = mutate_all(do_block, mutator, lines_to_mutate)
    {:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, mutated_do_block]}
  end

  def mutate_all([{construct, construct_body} | rest], mutator, lines_to_mutate) do
    mutated_construct_body = mutate_all(construct_body, mutator, lines_to_mutate)
    mutated_rest = mutate_all(rest, mutator, lines_to_mutate)

    [{construct, mutated_construct_body} | mutated_rest]
  end

  def mutate_all({operator, meta, args} = ast, mutator, lines_to_mutate) do
    case Enum.member?(lines_to_mutate, meta[:line]) do
      true ->
        case apply(mutator, :mutate, [ast, lines_to_mutate]) do
          :skip ->
            {operator, meta, mutate_all(args, mutator, lines_to_mutate)}

          mutated_ast ->
            mutated_ast
        end

      _ -> {operator, meta, mutate_all(args, mutator, lines_to_mutate)}
    end
  end

  def mutate_all([head | rest], mutator, lines_to_mutate) do
    [
      mutate_all(head, mutator, lines_to_mutate) |
      mutate_all(rest, mutator, lines_to_mutate)
    ]
  end

  def mutate_all(any, _mutator, _lines_to_mutate), do: any
end
