-module(type_check_tests).
-include_lib("eunit/include/eunit.hrl").


singleItem_test_() ->
    [
     ?_assertEqual({ok, all_valid}, type_check:validate(1, integer))
     , ?_assertEqual({ok, all_valid}, type_check:validate(hi, atom))
     , ?_assertEqual({ok, all_valid}, type_check:validate(<<>>, binary))
    ].


numbers_test_() ->
    [
     ?_assertEqual({ok, all_valid}, type_check:validate([1], [integer]))
     , ?_assertEqual({ok, all_valid}, type_check:validate([99999999999999], [integer]))

     , ?_assertEqual({ok, all_valid}, type_check:validate([1.0], [number]))
     , ?_assertEqual({ok, all_valid}, type_check:validate([99999999999.999], [number]))

     , ?_assertEqual({ok, all_valid}, type_check:validate([1.0, 2], [number, number]))

     %% error cases
     , ?_assertEqual({bad_types, [{1.0, integer}]}, type_check:validate([1.0], [integer]))
     , ?_assertEqual({bad_types, [{99999999999.999, integer}]}, type_check:validate([99999999999.999], [integer]))
     , ?_assertEqual({bad_types, [{hork, integer}]}, type_check:validate([hork], [integer]))
     , ?_assertEqual({bad_types, [{hork, number}, {berf, integer}]}
		     , type_check:validate([1.0, 2, hork, berf], [number, integer, number, integer]))
    ].


atom_test_() ->
    [
     ?_assertEqual({ok, all_valid}, type_check:validate([hork], [atom]))
     , ?_assertEqual({ok, all_valid}, type_check:validate(hork, atom))
     , ?_assertEqual({ok, all_valid}, type_check:validate('hork berf', atom))

     %% error cases
     , ?_assertEqual({bad_types, [{1.0, atom}]}, type_check:validate([1.0], [atom]))
    ].

-record(dummy_test, {field1=1, field2= <<"hi">>, field3}).
record_test_() ->
    [
     ?_assertEqual({ok, all_valid}, type_check:validate(#dummy_test{}, {atom, number, string, atom}))
    ].

%% TODO: list
%% TODO: each
%% TODO: eval_true
%% TODO: tuple

randomStuff_test_() ->
    [
     %% good cases
     ?_assertEqual({ok, all_valid}, type_check:validate([<<"hi">>, 1], [string, number]))
     , ?_assertEqual({ok, all_valid}, type_check:validate([<<"hi">>, 1, [1,2,3.0]]
							  , [string, number, {each, number}]))
     , ?_assertEqual({ok, all_valid}, type_check:validate([<<"hi">>, 1, {one, two, three}]
							  , [string, number, {atom, atom, atom}]))
     , ?_assertEqual({ok, all_valid}, type_check:validate([<<"hi">>, 1, {42, <<"the answer">>, [haha]}]
							  , [string, number, {integer, string, [atom]}]))

     %% unnecessary, but proving the feature works
     , ?_assertEqual({ok, all_valid}, type_check:validate([<<"hi">>], [{eval_true, fun is_binary/1}]))
     , ?_assertEqual({ok, all_valid}, type_check:validate([[1,2,3]], [{each, {eval_true, fun is_integer/1}}]))
     
     %% bad cases
     , ?_assertEqual({bad_types, [{arst, number}]}
		     , type_check:validate([<<"hi">>, 1, [1,2,arst]], [string, number, {each, number}]))
     , ?_assertMatch({bad_types, [{_, string}]}
		     , type_check:validate([<<"hi", 999999999>>, 1, [1,2,3.0]], [string, number, {each, number}]))
     , ?_assertMatch({bad_types, [{<<"you">>, number}]}
		     , type_check:validate([<<"hi">>, <<"you">>, [1,2,3.0]], [string, number, {each, number}]))
     , ?_assertMatch({bad_types, [{hork, {each, number}}]}
		     , type_check:validate([<<"hi">>, 1, hork], [string, number, {each, number}]))

     %% unnecessary, but proving the feature works
     , ?_assertEqual({ok, all_valid}, type_check:validate([<<"hi">>], [{eval_true, fun is_binary/1}]))
     , ?_assertEqual({ok, all_valid}, type_check:validate([[1,2,3]], [{each, {eval_true, fun is_integer/1}}]))
     
    ].
