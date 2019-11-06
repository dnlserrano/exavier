defmodule FooBar do
  def sub(a, b), do: a - b

  def list_sum(list), do: Enum.reduce(list, 0, &add/2)

  defp add(a, b), do: a + b
end
