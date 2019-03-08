defmodule ExavierTest do
  use ExUnit.Case
  doctest Exavier

  test "greets the world" do
    assert Exavier.hello() == :world
  end
end
