# exavier

![](logo.png)

A mutation testing library in Elixir. Inspired by [`pitest`](https://github.com/hcoles/pitest) (http://pitest.org) and [`mutant`](https://github.com/mbj/mutant).

## What is Mutation Testing?

> Mutation testing [...] is used to design new software tests and evaluate the quality of existing software tests. Mutation testing involves modifying a program in small ways. Each mutated version is called a mutant and tests detect and reject mutants by causing the behavior of the original version to differ from the mutant. This is called killing the mutant. Test suites are measured by the percentage of mutants that they kill. New tests can be designed to kill additional mutants.

\- [Wikipedia](https://en.wikipedia.org/wiki/Mutation_testing)

## How does `exavier` work?

The `exavier` library mutates code in **parallel per module**, but mutates each module **sequentially per mutator**. Initial code line coverage analysis is done **sequentially for all modules** as a pre-processing step. It is better explained as follows:

1. Run code line coverage analysis for each module, [sequentially](https://github.com/dnlserrano/exavier/commit/73daf82a28f0d6ef10f89b3ae21dd72c02127df1)
2. Mutate the code according to each available [mutator](#mutators)
    1. For each module, in parallel:
        1. For each mutator, sequentially:
            1. Mutate code with given mutator
            2. Run tests once again (now against mutated code)
            3. Record results (% mutants survived vs. killed)

### Mutators

Mutators specify ways in which we can mutate the code. Currently we have 5 proof-of-concept mutators available in `exavier`:

  - [AOR1](https://github.com/dnlserrano/exavier/blob/master/lib/exavier/mutators/aor1.ex)
  - [AOR2](https://github.com/dnlserrano/exavier/blob/master/lib/exavier/mutators/aor2.ex)
  - [ROR1](https://github.com/dnlserrano/exavier/blob/master/lib/exavier/mutators/ror1.ex)
  - [ROR4](https://github.com/dnlserrano/exavier/blob/master/lib/exavier/mutators/ror4.ex)
  - [IfTrue](https://github.com/dnlserrano/exavier/blob/master/lib/exavier/mutators/if_true.ex)

`AOR` stands for "Arithmetic Operator Replacement". There are several possibilities for replacing an arithmetic operator. We follow the ones defined by [`pitest`](http://pitest.org/quickstart/mutators/#available-mutators-and-groups). Similarly, `ROR` stands for "Relational Operator Replacement". `IfTrue` is inspired by `pitest`'s "Remove Conditionals".

You can create new mutators. You just have to make sure they abide to the interface provided by behaviour [`Exavier.Mutators.Mutator`](https://github.com/dnlserrano/exavier/blob/master/lib/exavier/mutators/mutator.ex):

```elixir
defmodule Exavier.Mutators.Mutator do
  @type operator() :: atom()
  @type metadata() :: keyword()
  @type args() :: term()

  @type ast_node() :: {operator(), metadata(), args()}
  @type lines_to_mutate() :: [integer()]

  @callback operators() :: [operator()]
  @callback mutate(ast_node(), lines_to_mutate()) :: ast_node() | :skip
end
```

An `Exavier.Mutators.Mutator` has two mandatory functions:

* `operators/0`
    1. input:
        * (none)
    2. output:
        * an array of atoms (operators to which the mutation can be applied, e.g., `[:==, :>=]`)

* `mutate/2`
    1. input:
        * AST node (e.g., `{operator, meta, args}`)
        * lines that should be mutated as part of that mutation (array of integers, e.g., `[3, 6]`)
    2. output:
        * mutated AST node (e.g., `{operator, meta, args}`)

## Installation

The package can be installed by adding `exavier` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exavier, "~> 0.1.1"}
  ]
end
```

Run `mix exavier.test` and you should see output similar to this:

```
......................

(...)

16) test when infinity (Elixir.HelloWorldTest)
  - if(y == :special) do
  -   :yes
  - else
  -   :no
  - end

  + if(true) do
  +   :yes
  + else
  +   :no
  + end

/Users/dnlserrano/Repos/exavier/test/hello_world_test.exs:10


22 tests, 6 failed (mutants killed), 16 passed (mutants survived)
27.27% mutation coverage
```

## To be done

This is for now just a proof-of-concept. A lot of it has been no more than a joyful exercise in exploring what tools Erlang and Elixir provide to make such a library possible. Among some things I'd love to tackle in the near future are:

- [ ] Add way more tests (OMG the irony, forgive me, this is still a bit of a PoC as you can tell by the length of this "To be done" section)
- [ ] Have exavier run as a CI step on exavier (Inception much?)
- [ ] Add mutators
  - [x] [AOR1](http://pitest.org/quickstart/mutators/#AOR)
  - [x] [AOR2](http://pitest.org/quickstart/mutators/#AOR)
  - [ ] [AOR3](http://pitest.org/quickstart/mutators/#AOR)
  - [ ] [AOR4](http://pitest.org/quickstart/mutators/#AOR)
  - [x] [ROR1](http://pitest.org/quickstart/mutators/#ROR)
  - [ ] [ROR2](http://pitest.org/quickstart/mutators/#ROR)
  - [ ] [ROR3](http://pitest.org/quickstart/mutators/#ROR)
  - [x] [ROR4](http://pitest.org/quickstart/mutators/#ROR)
  - [x] [Remove Conditionals](http://pitest.org/quickstart/mutators/#REMOVE_CONDITIONALS)
    - Can still be done for `case`, `unless`
  - [ ] [Conditionals Boundary](http://pitest.org/quickstart/mutators/#CONDITIONALS_BOUNDARY)
  - [ ] [Negate Conditionals](http://pitest.org/quickstart/mutators/#NEGATE_CONDITIONALS)
  - [ ] [Invert Negatives](http://pitest.org/quickstart/mutators/#INVERT_NEGS)
- [ ] Ability to tune which mutators are used
- [ ] Ability to add custom mutators defined by the user (i.e., not in `exavier`)
- [ ] Analyse if we really should or shouldn't care about pre-processing step of code line coverage
- [ ] Have other ways of terminating mutation test suite (e.g., fast-fail if threshold of X mutants have survived)
- [ ] Parallelise mutating module per mutator

## More info

- Discussion of the library at [ElixirForum.com](https://elixirforum.com/t/exavier-mutation-testing-library-for-elixir/24157)
- I wrote about `exavier` in my [personal blog](https://dnlserrano.dev/2019/07/22/exavier-mutation-testing-elixir.html)
- Always happy to chat in the `elixir-lang` Slack channel over at `#exavier`

## Library name

Inspired by [Dr. Charles Xavier (Professor X)](https://en.wikipedia.org/wiki/Professor_X) from the X-Men mutants comic books [I read as a kid](https://www.marvel.com/comics/series/474/ultimate_x-men_2000_-_2009).

## Acknowledgements

Thanks to Tita Moreira :heart: for putting up with my nerdiness.

Thanks to Richard A. DeMillo, Richard J. Lipton and Fred G. Sayward for their seminal work on Mutation Testing back in 1978, with the paper ["Hints on Test Data Selection: Help for the Practicing Programmer"](https://www.researchgate.net/publication/2957629_Hints_on_Test_Data_Selection_Help_for_the_Practicing_Programmer).

Thanks to Henry Coles for `pitest` and Markus Schirp for `mutant`, which served as an inspiration for this project.

## License

    Copyright © 2019-present Daniel Serrano <danieljdserrano at protonmail>

    This work is free. You can redistribute it and/or modify it under the
    terms of the MIT License. See the LICENSE file for more details.

Made in Portugal :portugal: by [dnlserrano](https://dnlserrano.dev)
