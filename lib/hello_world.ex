defmodule HelloWorld do
  require Exavier

  Exavier.mutate do
    def zero?(val), do: val == 0
  end
end
