defmodule Exavier.Config do
  @config_file ".exavier.exs"
  @config_file_content File.read!("priv/" <> @config_file)

  def get(key, default \\ nil) do
    case exists?() do
      true ->
        load_configs()
        |> do_get(key, default)

      _ ->
        default
    end
  end

  defp do_get(nil, _key, default), do: default
  defp do_get(configs, key, default), do: Map.get(configs, key, default)

  def ensure_loaded_configs do
    if exists?() do
      load_configs()
    end
  rescue
    _ ->
      raise("""
      Error reading configuration file \"#{config_file()}\".
      Make sure the content of your configuration file is a valid Elixir map.
      Alternatively, generate a sample configuration file via the mix task \"mix exavier.config\".
      """)
  end

  defp load_configs do
    {configs, _binding} =
      config_file()
      |> File.read!()
      |> Code.eval_string()

    configs
  end

  def exists?, do: config_file() |> File.exists?()

  def config_file, do: @config_file

  def config_file_content, do: @config_file_content
end
