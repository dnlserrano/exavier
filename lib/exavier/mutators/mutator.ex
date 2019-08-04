defmodule Exavier.Mutators.Mutator do
  @type operator() :: atom()
  @type metadata() :: keyword()
  @type args() :: term()

  @type ast_node() :: {operator(), metadata(), args()}
  @type lines_to_mutate() :: [integer()]

  @callback operators() :: [operator()]
  @callback mutate(ast_node(), lines_to_mutate()) :: ast_node() | :skip
end
