defmodule Exavier.Reporter do
  use GenServer

  # mutated_modules :: map
  # key :: module name :: string
  # value :: mutation info :: Exavier.Mutation
  defstruct mutated_modules: %{}, failed: 0, passed: 0

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, opts)
  end

  @impl GenServer
  def init(state), do: {:ok, state}

  @impl GenServer
  def handle_cast({:test_started, %ExUnit.Test{module: module}}, state) do
    next_state =
      module
      |> current_state(state)
      |> next_state()

    state = update_mutated_module_state(state, module, next_state)

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:test_finished, %ExUnit.Test{state: nil, module: module}}, state) do
    state = measure_mutation_survived(module, state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, _failed}, module: module}}, state) do
    state = measure_mutation_killed(module, state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:report, _from, state) do
    total = state.passed + state.failed
    percentage =
      (state.failed * 1.0 / total) * 100
      |> Float.round(2)

    message =
      "#{total} tests, #{state.failed} failed (mutants killed), #{state.passed} passed (mutants survived)\
    \n#{percentage}% mutation coverage"

    message =
      cond do
        percentage > 75 -> success(message)
        percentage > 70 -> warning(message)
        true -> failure(message)
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
    module_state = current_state(module, state)
    do_measure_mutation_killed(state, module_state)
  end

  defp do_measure_mutation_killed(state, :mutation) do
    success(".") |> IO.write()
    %{state | failed: state.failed + 1}
  end

  defp do_measure_mutation_killed(state, _module_state), do: state

  defp measure_mutation_survived(module, state) do
    module_state = current_state(module, state)
    do_measure_mutation_survived(state, module_state)
  end

  defp do_measure_mutation_survived(state, :mutation) do
    failure(".") |> IO.write()
    %{state | passed: state.passed + 1}
  end

  defp do_measure_mutation_survived(state, _module_state), do: state

  defp success(msg), do: colorize(:green, msg)
  defp warning(msg), do: colorize(:yellow, msg)
  defp failure(msg), do: colorize(:red, msg)

  defp current_state(module, state) do
    mutated_module = Map.get(state.mutated_modules, module)
    mutated_module && mutated_module.state
  end

  defp next_state(nil), do: :cover
  defp next_state(:cover), do: :mutation
  defp next_state(state), do: state

  defp update_mutated_module_state(state, module, module_state) do
    mutated_module = Map.get(state.mutated_modules, module) || %Exavier.Mutation{}

    mutated_modules =
      Map.put(state.mutated_modules, module, %{mutated_module | state: module_state})

    %{state | mutated_modules: mutated_modules}
  end
end
