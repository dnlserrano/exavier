defmodule Mix.Tasks.Exavier.Test do
  use Mix.Task

  @shortdoc "Runs mutation testing"
  def run(_args) do
    unless System.get_env("MIX_ENV") || Mix.env() == :test do
      Mix.raise(
        "\"mix test\" is running in the \"#{Mix.env()}\" environment. If you are " <>
          "running tests alongside another task, please set MIX_ENV explicitly"
      )
    end

    Mix.shell().print_app
    Mix.Task.run("app.start", [])

    case Application.load(:ex_unit) do
      :ok -> :ok
      {:error, {:already_loaded, :ex_unit}} -> :ok
    end

    config = Keyword.merge(
      ExUnit.configuration(),
      Application.get_all_env(:ex_unit)
    )

    ExUnit.configure(config)

    require_test_helper()

    mutation = Exavier.redefine("lib/hello_world.ex")
    require IEx; IEx.pry

    Code.require_file("test/hello_world_test.exs")
    Code.require_file("test/exavier_test.exs")
  end

  defp require_test_helper do
    file = Path.join("test", "test_helper.exs")

    if File.exists?(file) do
      Code.require_file(file)
    else
      Mix.raise("Cannot run tests because test helper file #{inspect(file)} does not exist")
    end
  end
end
