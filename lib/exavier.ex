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

    {:"Elixir.#{module_name}", quoted}
  end

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

  def unrequire_test_file(test_file) do
    test_file =
      Code.required_files()
      |> Enum.find(fn required_file ->
        String.contains?(required_file, test_file)
      end)

    Code.unrequire_files([test_file])
  end

  defp mutate_all({:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, do_block]}, mutator, lines_to_mutate) do
    mutated_do_block = mutate_all(do_block, mutator, lines_to_mutate)
    {:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, mutated_do_block]}
  end

  defp mutate_all([{construct, construct_body} | rest], mutator, lines_to_mutate) do
    mutated_construct_body = mutate_all(construct_body, mutator, lines_to_mutate)
    mutated_rest = mutate_all(rest, mutator, lines_to_mutate)

    [{construct, mutated_construct_body} | mutated_rest]
  end

  defp mutate_all({operator, meta, args}, mutator, lines_to_mutate) do
    case Enum.member?(lines_to_mutate, meta[:line]) do
      true ->
        mutated_args = mutate_all(args, mutator, lines_to_mutate)
        mutated_operator =
          case apply(mutator, :mutate, [operator]) do
            nil -> operator
            mutation -> mutation
          end

          {mutated_operator, meta, mutated_args}

      _ -> {operator, meta, mutate_all(args, mutator, lines_to_mutate)}
    end
  end

  defp mutate_all([head | rest], mutator, lines_to_mutate) do
    [
      mutate_all(head, mutator, lines_to_mutate) |
      mutate_all(rest, mutator, lines_to_mutate)
    ]
  end

  defp mutate_all(any, _mutator, _lines_to_mutate), do: any
end
