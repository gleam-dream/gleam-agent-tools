%% A client VM only: parse terms, confirm the node, execute one bounded RPC.
-module(beam_tool).
-export([main/0]).
main() ->
    try
        [Node, Module, Function, Arguments | Rest] = init:get_plain_arguments(),
        Timeout = case Rest of [] -> 5000; [T] -> list_to_integer(T) end,
        true = Timeout > 0 andalso Timeout =< 30000,
        {ok, Tokens, _} = erl_scan:string(Arguments ++ "."),
        {ok, Args} = erl_parse:parse_term(Tokens),
        true = is_list(Args),
        Target = list_to_atom(Node),
        Target = erpc:call(Target, erlang, node, [], min(Timeout, 2000)),
        io:format(standard_error, "confirmed_node=~s~n", [Node]),
        Value = erpc:call(Target, list_to_atom(Module), list_to_atom(Function), Args, Timeout),
        case Value of {error, _} -> fail("application_error: private details suppressed"); _ -> ok end,
        %% The caller must select an allowlisted projection, not customer state.
        Output = io_lib:format("~P", [Value, 20]),
        true = iolist_size(Output) =< 65536,
        io:put_chars([Output, "\n"]),
        halt(0)
    catch
        error:{erpc, noconnection} -> fail("node_unreachable: check selected Machine, user/cookie, name mode and loopback EPMD/listeners");
        error:{erpc, timeout} -> fail("rpc_timeout: mutation outcome may be unknown; inspect before retrying");
        error:{exception, undef, _} -> fail("target_export_unavailable: check packaged module and export");
        _:_ -> fail("rpc_failed: check arguments, target modules and application status; private error details suppressed")
    end.
fail(Message) -> io:format(standard_error, "~s~n", [Message]), halt(1).
