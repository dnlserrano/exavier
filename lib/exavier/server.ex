defmodule Exavier.Server do
  alias Exavier.State

  use GenServer

  @test_file_regexp ~r/^test(.*)_test.exs/
  @source_file_replacement "lib\\1.ex"

  def start_link(runner_pid) do
    GenServer.start_link(
      __MODULE__,
      %State{runner_pid: runner_pid},
      name: __MODULE__
    )
  end

  def init(%State{} = state) do
    {:ok, state}
  end

  def handle_cast(:xmen, state) do
    server = self()

    files()
    |> Enum.each(fn {file, test_file} ->
      Task.start(fn ->
        {module_name, quoted} = Exavier.AST.file_to_quoted(file)
        lines_to_mutate = Exavier.Cover.lines_to_mutate(module_name, test_file)

        Exavier.Mutators.mutators()
        |> Enum.each(fn mutator ->
          Exavier.redefine(quoted, mutator)
          Code.require_file(test_file)
          unrequire_test_file(test_file)
        end)

        GenServer.stop(server, :normal)
      end)
    end)

    {:noreply, state}
  end

  defp unrequire_test_file(test_file) do
    test_file =
      Code.required_files()
      |> Enum.find(fn required_file ->
        String.contains?(required_file, test_file)
      end)

    Code.unrequire_files([test_file])
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
end
