defmodule Exavier.Server do
  use GenServer

  @test_file_regexp ~r/^test(.*)_test.exs/
  @source_file_replacement "lib\\1.ex"

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call(:xmen, _from, state) do
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
    |> Task.async_stream(fn {
      test_file,
      %{file: file, module: module, lines_to_mutate: lines_to_mutate}
    } ->
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
    end)
    |> Enum.to_list()
    |> Enum.all?(&Kernel.==(&1, :ok))
    |> case do
      true -> :ok
      _ -> :error
    end

    {:reply, :ok, state}
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

  defp record_mutation(module, mutated_lines, original, mutated) do
    Process.whereis(:exavier_reporter)
    |> GenServer.cast({:mutation, module, mutated_lines, original, mutated})
  end
end
