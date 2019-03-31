defmodule Exavier.Mutation do
  def mutate({:<=, meta, args}) do
    {:==, meta, mutate_ast(args)}
  end

  def mutate({:==, meta, args}) do
    {:>=, meta, mutate_ast(args)}
  end

  defp mutate_ast(args) when is_list(args) do
    args
    |> Enum.map(fn arg ->
      mutate_ast(arg)
    end)
  end

  defp mutate_ast(any), do: any
end
