`type_check` is a generic run-time type checker for erlang terms.


## Examples

```erlang
{ok, all_valid} = type_check:validate(
     [<<"hi">>,      1, {42,      <<"the answer">>, [blah]}]
     , [string, number, {integer,           string, [atom]}])).

{bad_types, [{<<"you">>, number}]} = type_check:validate(
	[<<"hi">>, <<"there">>, [1,2,3.0]], 
	[  string,      number, {each, number}]).
```

See `test/type_check_tests.erl` for more examples, or better yet, just read the code. There's not much of it!


## Motivation

The one use-case in which I've really missed type checking is when
validating external client input. My worry isn't so much that
arguments of the wrong types will crash the system; my worry is that
they won't crash the system, and instead result in unexpected
behavior. At the very least, having the option to ensure arguments are
of the correct type or crash if not, offers a little peace of mind.


## Design

`type_check:validate/2` takes the `Value` to be checked, and a
declaration of the expected type signature. It returns either

 * `{ok, all_valid}`, or
 * `{bad_types, [{Value, ExpectedType}]}`


## Limitations

The returned list of `bad_types` can come from anywhere in the given
Value being checked, so in complex data structures, a bit of a hunt
for bad values may be required. 

I find this acceptable.

Submit a pull request if you do not!


## License

MIT (see LICENSE)