defmodule Config do
  @config_file ".exavier.exs"

  def get(key, default \\ nil) do
    {configs, _binding} =
      @config_file
      |> File.read!()
      |> Code.eval_string()

    Map.get(configs, key, default)
  end
end
