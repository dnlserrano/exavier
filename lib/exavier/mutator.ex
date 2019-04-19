defmodule Exavier.Mutator do
  def mutate({:<=, meta, args}) do
    {:==, meta, args}
  end

  def mutate({:==, meta, args}) do
    {:>=, meta, args}
  end

  def mutate({fun, meta, ["Hello World!"]}) do
    {fun, meta, ["Yoyo World!"]}
  end

  def mutate(other), do: other
end
