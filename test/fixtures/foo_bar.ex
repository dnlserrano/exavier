defmodule FooBar do
  def sub(a, b), do: a - b

  def list_sum(list) do
    Enum.reduce(list, 0, &add/2)
  end

  def div(a, b) when b != 0, do: a / b

  def div(_a, _b), do: -1

  defp add(a, b), do: a + b
end
