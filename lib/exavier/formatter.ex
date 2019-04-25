defmodule Exavier.Formatter do
  alias Exavier.State

  def output(%State{} = state) do
    IO.puts("TESTS:    #{state.tests}")
    IO.puts("KILLED:   #{state.killed}")
  end
end
