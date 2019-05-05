defmodule Exavier.Formatter do
  use GenServer

  @impl GenServer
  def init(_opts) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_cast({:test_finished, %ExUnit.Test{state: nil}} = event, state) do
    report(event)
    {:noreply, state}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, _failed}}} = event, state) do
    report(event)
    {:noreply, state}
  end

  def handle_cast(_event, state), do: {:noreply, state}

  defp report(event) do
    Process.whereis(:exavier_reporter)
    |> GenServer.cast(event)
  end
end
