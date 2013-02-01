%%%-------------------------------------------------------------------
%%% @author aj <AJ Heller <aj@drfloob.com>>
%%% @copyright (C) 2013, aj
%%%
%%% @doc Ensures arguments are of the specified type, used for
%%% validating unknown input
%%% @end
%%%
%%% Created : 29 Jan 2013 by aj <AJ Heller <aj@drfloob.com>>
%%%-------------------------------------------------------------------
-module(type_check).
-export([validate/2]).

validate(List, Types) 
  when is_list(List), is_list(Types), length(List) =:= length(Types) ->
    CheckList = lists:zip(List, Types),
    case collect_invalid(lists:map(fun validate_one/1, CheckList)) of
	[] ->
	    {ok, all_valid};
	Errors ->
	    {bad_types, Errors}
    end;

validate(Item, Spec) ->
    case validate_one({Item, Spec}) of
	true -> {ok, all_valid};
	{ok, all_valid} -> {ok, all_valid};
	{invalid, Err} -> {bad_types, [Err]}
    end.
	     


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Internal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% binary strings only
validate_one({Value, string}) when is_binary(Value) ->
    case heuristic_encoding_bin(Value) of
	utf8 -> true;
	_ -> {invalid, {Value, string}}
    end;
validate_one({Value, integer}) when is_integer(Value) ->
    true;
validate_one({Value, number}) when is_number(Value) ->
    true;
validate_one({Value, atom}) when is_atom(Value) ->
    true;
validate_one({Value, binary}) when is_binary(Value) ->
    true;

%% applies a predicate function to the Value, which must return the
%% atom true. This allows preexisting predicates in your models to be
%% reused for for input validation.
validate_one({Value, {eval_true, Fun}}) 
  when is_function(Fun, 1) ->
    case Fun(Value) of
	true -> true;
	_ -> 
	    {name, FunName} = erlang:fun_info(Fun, name),
	    {invalid, {Value, FunName}}
    end;

%% each value in the List must be of type Type
validate_one({ValueSet, {each, Type}}) when is_list(ValueSet) ->
    Types = [Type || _ <- ValueSet],
    validate(ValueSet, Types);

%% each value in the List must match the *corresponding* type in Type
%% i.e. validate([[1,hi]], [[number, atom]])
validate_one({ValueList, TypeList}) 
  when is_list(ValueList), is_list(TypeList), length(ValueList) =:= length(TypeList) ->
    validate(ValueList, TypeList);

%% each value in the Tuple must match its *corresponding* type Type
%% i.e. validate([{1,hi}], [{number, atom}])
validate_one({ValueTuple, TypeTuple}) 
  when is_tuple(ValueTuple), is_tuple(TypeTuple), tuple_size(TypeTuple) =:= tuple_size(ValueTuple) ->
    ValueList = tuple_to_list(ValueTuple),
    TypeList = tuple_to_list(TypeTuple),
    validate(ValueList, TypeList);

%% if not above, then invalid
validate_one(Invalid) ->
    {invalid, Invalid}.





%% modified from: http://www.erlang.org/doc/apps/stdlib/unicode_usage.html
heuristic_encoding_bin(Bin) when is_binary(Bin) ->
    case unicode:characters_to_binary(Bin,utf8,utf8) of
	Bin ->
	    utf8;
	_ ->
	    other
    end.




collect_invalid(Results) ->
    collect_invalid(Results, []).


collect_invalid([], Acc) ->
    lists:reverse(Acc);
collect_invalid([true|Rest], Acc) ->
    collect_invalid(Rest, Acc);
collect_invalid([{ok, all_valid}|Rest], Acc) ->
    %% the good nested case
    collect_invalid(Rest, Acc);
collect_invalid([{bad_types, BadTypes}|Rest], Acc) ->
    %% the bad nested case
    collect_invalid(Rest, lists:reverse(BadTypes) ++ Acc);
collect_invalid([{invalid, Err}|Rest], Acc) ->
    collect_invalid(Rest, [Err|Acc]).



