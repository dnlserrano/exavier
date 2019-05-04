defmodule Exavier.Formatter do
  use GenServer

  defstruct cases: %{}

  @impl GenServer
  def init(_opts) do
    {:ok, %__MODULE__{}}
  end

  @impl GenServer
  def handle_cast({:suite_finished, _run_us, _load_us}, config) do
    IO.puts("[formatter] suite finished")
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: nil} = test}, config) do
    IO.puts("[formatter] test finished successfully #{inspect(test)}")
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:skip, _}}}, config) do
    IO.puts("[formatter] test finished skip")
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:excluded, _}}}, config) do
    IO.puts("[formatter] test finished excluded")
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, _failed}}}, config) do
    IO.puts("[formatter] test finished failed")
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:invalid, _module}}}, config) do
    IO.puts("[formatter] test finished invalid")
    {:noreply, config}
  end

  def handle_cast(_event, config), do: {:noreply, config}
end
