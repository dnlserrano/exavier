defmodule Exavier.Cover do
  require Logger

  def lines_to_mutate(module_name, test_file) do
    :cover.stop()
    :cover.start()

    {:ok, :compiled} = cover_compile(module_name, test_file)

    Code.require_file(test_file)
    Exavier.unrequire_file(test_file)
    ExUnit.Server.modules_loaded()
    ExUnit.run()

    {:result, coverage_results, _failures} = :cover.analyse(:coverage, :line)

    coverage_results
    |> covered_lines()
  end

  defp covered_lines(coverage_results) do
    coverage_results
    |> Enum.reduce([], fn {{_module, line}, coverage}, covered_lines ->
      case line != 0 && coverage == {1, 0} do
        true -> [line | covered_lines]
        _ -> covered_lines
      end
    end)
    |> Enum.reverse()
  end

  defp cover_compile(module_name, test_file) do
    case :cover.compile_beam(module_name) do
      {:error, :non_existing} ->
        load_non_default_module_name(module_name, test_file)
      {:ok, _} -> {:ok, :compiled}
    end
  end

  defp load_non_default_module_name(module_name, test_file) do
    non_default_module_name =
      Application.get_env(:exavier, :test_files_to_modules)
      |> do_load_non_default_module_name(test_file)

    case non_default_module_name do
      {:error, :non_existing_override} ->
        Logger.error("Could not find module #{module_name} inferred from test file #{test_file}. You can define your overrides using the :test_files_to_modules option in exavier.")

      _ ->
        case :cover.compile_beam(non_default_module_name) do
          {:error, :non_existing} ->
            Logger.error("Could not find module #{non_default_module_name} defined in option :test_files_to_modules for #{test_file}.")

          {:ok, _} -> {:ok, :compiled}
        end
    end
  end

  defp do_load_non_default_module_name(nil, _test_file) do
    {:error, :non_existing_override}
  end

  defp do_load_non_default_module_name(test_files_to_modules, test_file) do
    Map.get(test_files_to_modules, test_file)
  end
end
