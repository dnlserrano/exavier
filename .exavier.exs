%{
  threshold: 27,
  test_files_to_modules: %{
    "test/exavier/mutators/aor1_test.exs" => Exavier.Mutators.AOR1,
    "test/exavier/mutators/aor2_test.exs" => Exavier.Mutators.AOR2,
    "test/exavier/mutators/ror1_test.exs" => Exavier.Mutators.ROR1,
    "test/exavier/mutators/ror4_test.exs" => Exavier.Mutators.ROR4,
    "test/exavier/mutators/icm1_test.exs" => Exavier.Mutators.ICM1
  }
}
