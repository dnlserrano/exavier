defmodule HelloWorld do
  def even?(:infinity), do: nil
  def even?(x), do: rem(x, 2) == 0
end
