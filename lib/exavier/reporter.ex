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
    failure(".") |> IO.write()
    state = %{state | passed: state.passed + 1}
    {:noreply, state}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, _failed}}}, state) do
    success(".") |> IO.write()
    state = %{state | failed: state.failed + 1}
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

  defp success(msg), do: colorize(:green, msg)
  defp warning(msg), do: colorize(:yellow, msg)
  defp failure(msg), do: colorize(:red, msg)
end
