defmodule Exavier.Formatter do
  alias Exavier.State

  def output(%State{stats: stats}) do
    IO.puts("STATS: #{stats}")
  end
end
