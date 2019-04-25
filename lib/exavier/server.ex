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

    files
    |> Enum.each(fn {file, test_file} ->
      Task.start(fn ->
        # mutate and test
        mutation = Exavier.redefine(file)
        Code.require_file(test_file)

        # collect test stats
        stats = ExUnit.RunnerStats.stats(self())
        IO.inspect(stats, label: "stats for #{inspect(files)}")
        GenServer.cast(server, {:update, files, stats})
      end)
    end)

    {:noreply, state}
  end

  def handle_cast({:update, files, stats}, state) do
    state = %State{stats: state.stats ++ [{files, stats}]}
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
end
