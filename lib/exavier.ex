defmodule Exavier do
  @moduledoc """
  Documentation for Exavier.
  """

  @default_timeout 5000
  @timeouts %{
    mutate_module: 5000,
    mutate_everything: 60_000,
    report: 1000,
  }

  def file_to_quoted(file) do
    file
    |> File.read!()
    |> Code.string_to_quoted!()
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
    |> String.trim_leading("test/")
    |> String.trim_trailing("_test.exs")
    |> String.trim_trailing("_test.ex")
    |> String.split("/")
    |> Enum.map(&Macro.camelize(&1))
    |> Enum.join(".")
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
  end

  def quoted_to_string(_anything, _lines), do: nil

  def redefine(original, mutator, lines_to_mutate) do
    {mutated_lines, mutated} =
      original
      |> mutate_all(mutator, lines_to_mutate, [])

    mutated
    |> Code.compile_quoted()

    {mutated_lines, original, mutated}
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
    String.to_atom(module_name)
  end

  defp string_to_elixir_module(module_name) do
    String.to_atom("Elixir.#{module_name}")
  end

  def mutate_all(ast, mutator, lines_to_mutate, already_mutated_lines \\ [])

  def mutate_all(
    {:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, do_block]},
    mutator, lines_to_mutate, already_mutated_lines
  ) do
    {mutated_lines, mutated_do_block} =
      mutate_all(do_block, mutator, lines_to_mutate, already_mutated_lines)

    {mutated_lines,
      {:defmodule, mod_meta, [{:__aliases__, alias_meta, [module_name]}, mutated_do_block]}}
  end

  def mutate_all(
    [{operator, body} | rest],
    mutator, lines_to_mutate, already_mutated_lines
  ) do
    {mutated_lines_body, mutated_body} =
      mutate_all(body, mutator, lines_to_mutate, already_mutated_lines)

    {mutated_lines_body_rest, mutated_rest} =
      mutate_all(rest, mutator, lines_to_mutate, mutated_lines_body)

    {mutated_lines_body_rest, [{operator, mutated_body} | mutated_rest]}
  end

  def mutate_all({:&, meta, args} = _ast, mutator, lines_to_mutate, already_mutated_lines) do
    current_line = meta[:line]
    {mutated_lines, mutated_args} =
      case Enum.member?(lines_to_mutate, current_line) do
        true ->
          mutate_all(args, mutator, List.delete(lines_to_mutate, current_line), [current_line | already_mutated_lines])
        _ ->
          mutate_all(args, mutator, lines_to_mutate, already_mutated_lines)
        end
    {mutated_lines, {:&, meta, mutated_args}}
  end

  def mutate_all(
    {operator, meta, args} = ast, mutator, lines_to_mutate, already_mutated_lines
  ) do
    case Enum.member?(lines_to_mutate, meta[:line]) do
      true ->
        case apply(mutator, :mutate, [ast, lines_to_mutate]) do
          :skip ->
            {mutated_lines, mutated_args} =
              mutate_all(args, mutator, lines_to_mutate, already_mutated_lines)

            {mutated_lines, {operator, meta, mutated_args}}

          mutated_ast ->
            mutated_lines =
              already_mutated_lines ++ [meta[:line]]
              |> Enum.uniq()

            {mutated_lines, mutated_ast}
        end

      _ ->
        {mutated_lines, mutated_args} =
          mutate_all(args, mutator, lines_to_mutate, already_mutated_lines)

        {mutated_lines, {operator, meta, mutated_args}}
    end
  end

  def mutate_all([head | rest], mutator, lines_to_mutate, already_mutated_lines) do
    {mutated_lines_head, mutated_head} = mutate_all(head, mutator, lines_to_mutate, already_mutated_lines)
    {mutated_lines_head_rest, mutated_rest} = mutate_all(rest, mutator, lines_to_mutate, mutated_lines_head)

    {mutated_lines_head_rest, [mutated_head | mutated_rest]}
  end

  def mutate_all(any, _mutator, _lines_to_mutate, already_mutated_lines), do: {already_mutated_lines, any}

  def timeout(name) do
    do_timeout(name, debug: System.get_env("EXAVIER_DEBUG"))
  end

  defp do_timeout(_name, debug: "1"), do: :infinity
  defp do_timeout(_name, debug: "true"), do: :infinity

  defp do_timeout(name, debug: _) do
    Map.get(@timeouts, name, @default_timeout)
  end
end
