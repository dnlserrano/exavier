defmodule Exavier.Reporter do
  use GenServer

  defstruct failed: 0, passed: 0

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, opts)
  end

  @impl GenServer
  def init(state), do: {:ok, state}

  @impl GenServer
  def handle_cast({:test_finished, %ExUnit.Test{state: nil}}, state) do
    IO.puts("Mutant survived")
    state = %{state | passed: state.passed + 1}
    {:noreply, state}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, _failed}}}, state) do
    state = %{state | failed: state.failed + 1}
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:report, _from, state) do
    total = state.passed + state.failed
    percentage =
      (state.failed * 1.0 / total) * 100
      |> Float.round(2)
      |> Float.to_string


    case state.passed > 0 do
      true -> IO.puts("Exavier reports: \"Some mutants have survived\"")
      _ -> IO.puts("Exavier reports: \"All mutants have been killed\"")
    end

    IO.puts("Total test runs: #{total}")
    IO.puts("Tests failed (mutants killed): #{state.failed}")
    IO.puts("Tests passed (mutants survived): #{state.passed}")
    IO.puts("Mutation coverage: #{percentage}%")

    {:reply, :ok, state}
  end
end
