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

    files()
    |> Enum.each(fn {file, test_file} ->
      Task.start(fn ->
        {module_name, quoted} = Exavier.file_to_quoted(file)
        lines_to_mutate = Exavier.Cover.lines_to_mutate(module_name, test_file)

        Exavier.Mutators.mutators()
        |> Enum.each(fn mutator ->
          case Exavier.redefine(quoted, mutator, lines_to_mutate) do
            {:mutated, original, mutated} ->
              record_mutation(test_file, lines_to_mutate, original, mutated)
              Code.require_file(test_file)
              Exavier.unrequire_file(test_file)
              ExUnit.Server.modules_loaded()
              ExUnit.run()

            _ -> :noop
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

  defp record_mutation(test_file, mutated_lines, original, mutated) do
    module = Exavier.test_file_to_module(test_file)

    Process.whereis(:exavier_reporter)
    |> GenServer.cast({:mutation, module, mutated_lines, original, mutated})
  end
end
