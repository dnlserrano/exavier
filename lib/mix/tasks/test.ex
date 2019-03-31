defmodule Mix.Tasks.Exavier.Test do
  use Mix.Task

  alias Mix.Compilers.Test, as: CT
  alias Mix.Tasks.Test.Cover

  @test_dir ["test"]
  @cover [output: "cover", tool: Cover]

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

    cover =
      Mix.Project.config()
      |> Mix.Project.compile_path()
      |> @cover[:tool].start(@cover)

    require_test_helper()

    test_files = Mix.Utils.extract_files(@test_dir, "*_test.exs")

    case CT.require_and_run(test_files, @test_dir, []) do
      {:ok, %{failures: failures}} ->
        cover && cover.()

        cond do
          failures > 0 ->
            System.at_exit(fn _ -> exit({:shutdown, 1}) end)

          true ->
            :ok
        end
    end
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
