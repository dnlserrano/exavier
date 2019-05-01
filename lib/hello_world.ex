defmodule HelloWorld do
  def zero?(val), do: val == 0

  def divide(a, b) do
    if b == 0 do
      0
    else
      a / b
    end
  end

  def sum_square(a, b) do
    a * a + b * b
  end
end
