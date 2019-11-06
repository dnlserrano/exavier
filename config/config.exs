use Mix.Config

config :exavier,
  test_files_to_modules: %{
    "test/exavier/mutators/aor1_test.exs" => Exavier.Mutators.AOR1,
    "test/exavier/mutators/aor2_test.exs" => Exavier.Mutators.AOR2,
    "test/exavier/mutators/ror1_test.exs" => Exavier.Mutators.ROR1,
    "test/exavier/mutators/ror4_test.exs" => Exavier.Mutators.ROR4
  },
  threshold: 27

config :exavier, test_file_to_module_func: [Exavier, :test_file_to_phoenix_module_func]
