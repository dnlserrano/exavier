defmodule Mix.Tasks.Exavier.Config do
  use Mix.Task

  alias Exavier.Config, as: C

  @shortdoc "Generates base config file"
  def run(_args) do
    file = C.config_file()

    if C.exists?() do
      IO.puts("Config file #{file} already exists")
    else
      content = C.config_file_content()
      File.write!(file, content)
      IO.puts("Generated config file " <> file)
    end
  end
end
