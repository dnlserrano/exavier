defmodule ExavierWeb.FakeView do
    def pow(x,n) do
        x
        |> :math.pow(n)
        |> round
    end
  end
