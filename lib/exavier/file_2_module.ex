defmodule Exavier.File2Module do
  def my_func(test_file) do
    test_file
    |> String.trim_leading("test/")
    |> String.trim_trailing("_test.exs")
    |> String.trim_trailing("_test.ex")
    |> trim_web_modules()
    |> String.split("/")
    |> Enum.map(&Macro.camelize(&1))
    |> Enum.join(".")
    |> string_to_elixir_module()
  end

  def trim_web_modules(test_file) do
    test_file
    |> String.replace("/controllers/", "/")
    |> String.replace("/views/", "/")
  end

  defp string_to_elixir_module("Elixir." <> _rest = module_name) do
    String.to_atom(module_name)
  end

  defp string_to_elixir_module(module_name) do
    String.to_atom("Elixir.#{module_name}")
  end
end
