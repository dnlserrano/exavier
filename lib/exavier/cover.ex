defmodule Exavier.Cover do
  def lines_to_mutate(module_name, test_file) do
    :cover.stop()
    :cover.start()
    :cover.compile_beam(module_name)

    Code.require_file(test_file)
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
end
