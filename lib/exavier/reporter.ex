defmodule Exavier.Reporter do
  use GenServer

  # mutated_modules :: map
  #   * key :: module name :: string
  #   * value :: mutation info :: Exavier.Mutation
  defstruct mutated_modules: %{}, all_failures: []

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, opts)
  end

  @impl GenServer
  def init(state), do: {:ok, state}

  @impl GenServer
  def handle_cast({:mutation, module, mutated_lines, original, mutation}, state) do
    mutated_module = mutated_module(state, module)

    mutated_modules =
      Map.put(state.mutated_modules, module, %{
        mutated_module |
        status: :recording,
        original: original,
        mutation: mutation,
        mutated_lines: mutated_lines
      })

    {:noreply, %{state | mutated_modules: mutated_modules}}
  end

  @impl GenServer
  def handle_cast({:test_finished, %ExUnit.Test{state: nil, module: test_module} = test}, state) do
    module = Exavier.test_module_to_module(test_module)
    state = measure_mutation_survived(module, test, state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, _failed}, module: test_module}}, state) do
    module = Exavier.test_module_to_module(test_module)
    state = measure_mutation_killed(module, state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:report, _from, state) do
    failed =
      state.mutated_modules
      |> Enum.reduce(0, fn {_, info}, sum -> info.failed + sum end)

    passed =
      state.mutated_modules
      |> Enum.reduce(0, fn {_, info}, sum -> info.passed + sum end)

    total = passed + failed
    percentage =
      (failed * 1.0 / total) * 100
      |> Float.round(2)

    IO.puts("\n")

    state.all_failures
    |> Enum.with_index()
    |> Enum.each(fn {{original, mutated, test}, i} ->
      tags = test.tags

      IO.write("#{i + 1}) #{tags.test} (#{tags.module})\n")
      IO.write("#{red(original)}\n")
      IO.write("#{green(mutated)}\n")
      IO.write("#{tags.file}:#{tags.line}\n")
      IO.write("\n")
    end)

    message =
      "#{total} tests, #{failed} failed (mutants killed), #{passed} passed (mutants survived)\
    \n#{percentage}% mutation coverage"

    message =
      cond do
        percentage > 75 -> green(message)
        true -> red(message)
      end

    IO.puts("\n#{message}")

    {:reply, :ok, state}
  end

  defp colorize(escape, string) do
    [escape, string, :reset]
    |> IO.ANSI.format_fragment(true)
    |> IO.iodata_to_binary()
  end

  defp measure_mutation_killed(module, state) do
    mutated_module = mutated_module(state, module)
    do_measure_mutation_killed(module, mutated_module, state)
  end

  defp do_measure_mutation_killed(module, %{status: :recording} = mutated_module, state) do
    failed = mutated_module.failed + 1
    mutated_modules =
      Map.put(state.mutated_modules, module, %{mutated_module | failed: failed})

    green(".") |> IO.write()

    %{state | mutated_modules: mutated_modules}
  end

  defp do_measure_mutation_killed(_, _, state), do: state

  defp measure_mutation_survived(module, test, state) do
    mutated_module = mutated_module(state, module)
    do_measure_mutation_survived(module, mutated_module, test, state)
  end

  defp do_measure_mutation_survived(module, %{status: :recording} = mutated_module, test, state) do
    passed = mutated_module.passed + 1
    mutated_modules =
      Map.put(state.mutated_modules, module, %{mutated_module | passed: passed})

    all_failures = state.all_failures ++ [explain(module, test, state)]

    red(".") |> IO.write()

    %{state | mutated_modules: mutated_modules, all_failures: all_failures}
  end

  defp do_measure_mutation_survived(_, _, _, state), do: state

  defp explain(module, test, state) do
    mutated_module = mutated_module(state, module)

    original =
      mutated_module.original
      |> Exavier.quoted_to_string(mutated_module.mutated_lines)

    mutated =
      mutated_module.mutation
      |> Exavier.quoted_to_string(mutated_module.mutated_lines)

    {original, mutated, test}
  end

  defp green(msg), do: colorize(:green, msg)
  defp red(msg), do: colorize(:red, msg)

  defp mutated_module(state, module) do
    Map.get(state.mutated_modules, module) || %Exavier.Mutation{}
  end
end
