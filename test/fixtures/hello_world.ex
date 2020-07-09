defmodule HelloWorld do
  def even?(:infinity), do: nil
  def even?(x), do: rem(x, 2) == 0

  def special?(y) when y in [:special, :not_special] do
    if y == :special do
      :yes
    else
      :no
    end
  end

  def lie_to_me?(true), do: true
  def lie_to_me?(false), do: false
end
