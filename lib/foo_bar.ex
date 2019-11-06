defmodule FooBar do
  def sub(a, b), do: a - b

  def list_sum(list) do
    Enum.reduce(list, 0, &add/2)
  end

  def div(a, b) when b != 0, do: a / b

  defp add(a, b), do: a + b
end
