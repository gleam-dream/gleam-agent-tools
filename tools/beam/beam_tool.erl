%% Operator-side client. The target needs only the exported functions being used.
-module(beam_tool).
-export([main/0, eval/0]).

main() -> execute(fun() ->
    [Node, Module, Function, Arguments | Rest] = init:get_plain_arguments(),
    Timeout = timeout(Rest),
    {ok, Tokens, _} = erl_scan:string(Arguments ++ "."),
    {ok, Args} = erl_parse:parse_term(Tokens),
    true = is_list(Args),
    Target = confirm(Node, Timeout),
    erpc:call(Target, list_to_atom(Module), list_to_atom(Function), Args, Timeout)
end).

%% Parse on the client; interpret on the target with stdlib, without installing
%% application modules or invoking a compiler. This is trusted operator access.
eval() -> execute(fun() ->
    [Node | Rest] = init:get_plain_arguments(),
    Timeout = timeout(Rest),
    ok = io:setopts(standard_io, [binary]),
    Source = read_source([], 65536),
    {ok, Tokens, _} = erl_scan:string(Source),
    {ok, Expressions} = erl_parse:parse_exprs(Tokens),
    Target = confirm(Node, Timeout),
    {value, Value, _} = erpc:call(Target, erl_eval, exprs, [Expressions, []], Timeout),
    Value
end).

timeout(Rest) ->
    T = case Rest of [] -> 5000; [Text] -> list_to_integer(Text) end,
    true = T > 0 andalso T =< 30000,
    T.

confirm(Node, Timeout) ->
    Target = list_to_atom(Node),
    Target = erpc:call(Target, erlang, node, [], min(Timeout, 2000)),
    io:format(standard_error, "confirmed_node=~s~n", [Node]),
    Target.

read_source(Parts, Remaining) ->
    case file:read(standard_io, min(4096, Remaining + 1)) of
        eof -> unicode:characters_to_list(iolist_to_binary(lists:reverse(Parts)));
        {ok, Data} ->
            Bytes = iolist_size(Data),
            true = Bytes =< Remaining,
            read_source([Data | Parts], Remaining - Bytes)
    end.

execute(Call) ->
    try
        Value = Call(),
        case Value of {error, _} -> fail("application_error: private details suppressed"); _ -> ok end,
        %% Ad hoc expressions must select safe fields; this is not redaction.
        Output = io_lib:format("~P", [Value, 20]),
        true = iolist_size(Output) =< 65536,
        io:put_chars([Output, "\n"]),
        halt(0)
    catch
        error:{erpc, noconnection} -> fail("node_unreachable: check selected instance, user/cookie, name mode and loopback EPMD/listeners");
        error:{erpc, timeout} -> fail("rpc_timeout: mutation outcome may be unknown; inspect before retrying");
        error:{exception, undef, _} -> fail("target_export_unavailable: check module and export");
        _:_ -> fail("rpc_failed: check input, target modules and application status; private error details suppressed")
    end.
fail(Message) -> io:format(standard_error, "~s~n", [Message]), halt(1).
