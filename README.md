## Why this project died, and what I'm doing instead.

I'm leaving this here to help those who come barking up the same tree.

In building this tool, I realized I was trying to implement a compiler
(parser & generator) for erlang terms.

The original use case for this project is: when accepting input from
unknown clients, before performing any resource-intensive tasks, the
input needs to be checked for well-formedness (e.g. no atoms when
strings are expected, no lists of integers where utf8 binary strings
are expected, etc.). If anything is wrong, *all* syntactical problems
with the input term should be reported (not just the first to
fail). If the input is well-formed, it would then be translated into
an internal format.

This is essentially a compiler from one erlang format to another,
based on a model-specific grammar. 

Instead I've chosen to implement parsing and compilation as basic
erlang functions for each model: `parse` and `create`,
respectively. It seems the most pragmatic solution, but the code isn't
terribly succinct, nor is it a solution that lends itself immediately
to much reuse.

Please ping me if you find a better solution!

### Work that came before:

 * Erlang [Match Specs](http://www.erlang.org/doc/apps/erts/match_spec.html) implement almost exactly what I need, but (evidently) cannot be used efficiently for matching arbitrary terms.
 * [One way](http://erlang.org/pipermail/erlang-questions/2003-November/010712.html) to use Match Specs for matching arbitrary terms.
 * Daniel Luna's [Erlang-type-checker](https://github.com/dLuna/Erlang-type-checker) operates on `-spec`s, which are available in `debug_info` builds (here's a [mailing list thread](http://erlang.org/pipermail/erlang-questions/2011-September/061343.html) about it).
 * [This thread](http://erlang.org/pipermail/erlang-questions/2008-October/039402.html) gets into metaprogramming and a bit about Match Spec reuse.
 * [Neotoma](https://github.com/seancribbs/neotoma) and [Yecc](http://www.erlang.org/doc/man/yecc.html) for parsing strings based on PEGs ([Parsing Expression Grammars](http://en.wikipedia.org/wiki/Parsing_expression_grammar)).

----

`type_check` is a generic run-time type checker for erlang terms.


## Examples

```erlang
{ok, all_valid} = type_check:validate(
     [<<"hi">>,      1, {     42, <<"the answer">>, [blah]}]
     , [string, number, {integer,           string, [atom]}]).

{bad_types, [{<<"there">>, number}]} = type_check:validate(
	[<<"hi">>, <<"there">>, [1,2,3.0]], 
	[  string,      number, {each, number}]).
```

See `test/type_check_tests.erl` for more examples, or better yet, just
read the code. There's not much of it!


## Motivation

The one use-case in which I've really missed type checking is when
validating external client input. My worry isn't so much that
arguments of the wrong types will crash the system; my worry is that
they won't crash the system, and instead result in unexpected
behavior. At the very least, having the option to ensure arguments are
of the correct type or crash if not, offers a little peace of mind.


## Design

`type_check:validate/2` takes the `Value` to be checked, and a
declaration of the expected `Type` signature. It returns either

 * `{ok, all_valid}`, or
 * `{bad_types, [{GivenValue, ExpectedType}]}`


## Limitations

The returned list of `bad_types` can come from anywhere in the given
`Value` being checked, so in complex data structures, a bit of a hunt
for bad values may be required.


## License

MIT (see LICENSE)