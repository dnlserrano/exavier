defmodule Exavier.Server do
  use GenServer

  defstruct runner_pid: nil

  @test_file_regexp ~r/^test(.*)_test.exs/
  @source_file_replacement "lib\\1.ex"

  def start_link(runner_pid) do
    GenServer.start_link(
      __MODULE__,
      %__MODULE__{runner_pid: runner_pid},
      name: __MODULE__
    )
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(:xmen, state) do
    server = self()

    # coverage is checked sequentially
    lines_to_mutate_by_module =
      files()
      |> Enum.reduce(%{}, fn {file, test_file}, acc ->
        module = Exavier.test_file_to_module(test_file)
        lines_to_mutate = Exavier.Cover.lines_to_mutate(module, test_file)

        Map.put(acc, test_file, %{
          file: file,
          module: module,
          lines_to_mutate: lines_to_mutate
        })
      end)

    # mutations are applied in parallel (for each module)
    lines_to_mutate_by_module
    |> Enum.each(fn {
      test_file, %{file: file, module: module, lines_to_mutate: lines_to_mutate}
    } ->
      Task.start(fn ->
        quoted = Exavier.file_to_quoted(file)

        Exavier.Mutators.mutators()
        |> Enum.each(fn mutator ->
          case Exavier.redefine(quoted, mutator, lines_to_mutate) do
            {[], _, _} -> :noop

            {mutated_lines, original, mutated} ->
              record_mutation(module, mutated_lines, original, mutated)
              Code.require_file(test_file)
              Exavier.unrequire_file(test_file)
              ExUnit.Server.modules_loaded()
              ExUnit.run()
          end
        end)

        # TODO:
        # only terminate after all tasks are complete
        GenServer.stop(server, :normal)
      end)
    end)

    {:noreply, state}
  end

  def test_files, do: Path.wildcard("test/**/*_test.exs")

  def files do
    test_files()
    |> Enum.map(fn test_file ->
      file =
        test_file
        |> String.replace(@test_file_regexp, @source_file_replacement)

      {file, test_file}
    end)
  end

  def terminate(:normal, state) do
    send(state.runner_pid, {:end, state})
  end

  defp record_mutation(module, mutated_lines, original, mutated) do
    Process.whereis(:exavier_reporter)
    |> GenServer.cast({:mutation, module, mutated_lines, original, mutated})
  end
end
