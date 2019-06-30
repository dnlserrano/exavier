defmodule Exavier.Mutation do
  defstruct [
    status: :not_recording,
    mutated_lines: [],
    failed: 0,
    passed: 0,
    original: nil,
    mutation: nil
  ]
end
