%% @doc Run handler.
-module(run_handler).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([charsets_accepted/2]).

-export([from_json/2]).
-include("message_templates.hrl").

-export([execute/1]).

%-define(TEST,1).
-ifdef(TEST).
-define(DBG(Message),io:format("Module: ~p, Line:~p, :~p~n",[?MODULE ,?LINE, Message])).
-else.
-define(DBG(Message),true).
-endif.

init(Req, Opts) ->
 _Headers = cowboy_req:headers( Req),
   %% Headers = cowboy_req:meta(media_type,Req),
    ?DBG([[_Headers]]),
    {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
        {[<<"GET">>, <<"POST">>], Req, State}.

charsets_accepted(Req, State) ->
    {[<<"utf-8">>,<<"UTF-8">>], Req, State}.

content_types_provided(Req, State) ->
    {[
      {<<"application/json">>, list_to_json}
     ], Req, State}.

content_types_accepted(Req, State) ->
    {[
      {{<<"application">>, <<"json">>, [{<<"charset">>, <<"utf-8">>}]},from_json}
	  ], Req, State}.

from_json(Req, State) ->
    ?DBG(["from json"]),
    case cowboy_req:method(Req) of
	<<"POST">> ->
	?DBG(["POST received"]), 
	?DBG(["Request run"]),
	{ok,ReqBody,Req2} = cowboy_req:body(Req),
	[{<<"data">>,Selected}] = jsx:decode(ReqBody),	
	?DBG(Selected),
	ListOfTc = selected_tc_to_list(Selected),
	?DBG(ListOfTc),

	ExecutionStrings =  list_of_tc_to_exe_string(ListOfTc),
	?DBG(ExecutionStrings),
	execute(ExecutionStrings),
	Response = jsx:encode([{<<"result">>,true}]),
	?DBG(Response),
	{true,cowboy_req:set_resp_body(Response,Req2),State};
	        _ ->
	    {true, Req, State}
    end.
execute([]) -> [];
execute([ExecutionString|Tail]) ->
    CT_RUN = application:get_env(web_server,cmd_ct_run,[]),
    ?DBG(CT_RUN ++ ExecutionString),
    Port = erlang:open_port({spawn,CT_RUN ++ ExecutionString},
			    [stderr_to_stdout,in,binary,exit_status,stream,{line,255}]),
    execution_loop(Port,Tail).
execution_loop(Port,Tail) ->
    receive 
	{Port, {exit_status,_Status}} ->
	    ?DBG("End of suite"),
	    execute(Tail);
	{Port,_Data}->
	    ?DBG(_Data),
	    execution_loop(Port,Tail)
    end.

list_of_tc_to_exe_string(ListOfTc) ->
    Suites = proplists:get_keys(ListOfTc),  
    ?DBG(Suites),
    lists:foldl(fun(Suite,AccSuite) ->
			CasesStr = 
			    lists:foldl(fun(X,Acc)->" " ++ X ++Acc end,
					[],
					proplists:get_all_values(Suite,ListOfTc)),
			SuiteToLoad = load_suite_path(Suite),
			[" -suite " ++ SuiteToLoad ++" -case" ++ CasesStr | AccSuite] end,
		[], 
		Suites).


selected_tc_to_list(JsonListSelectedTc)->
    lists:foldl(fun(X, Acc)->	
			BinaryEncodedPath = proplists:get_value(<<"path">>,X),
			UrlStringPath = binary_to_list(BinaryEncodedPath),
			ListPath =re:split(UrlStringPath,"%2F",[{return,list}]),
			StringSuite = lists:last(ListPath),
			BinaryEncodedTc = proplists:get_value(<<"tc">>,X),
			StringTc = binary_to_list(BinaryEncodedTc),
			[{StringSuite,StringTc}|Acc] end,[], JsonListSelectedTc).

load_suite_path(Suite) ->
    case application:get_env(web_server,use_tmp_beams,false) of
	false ->  Suite;
	true -> 
	    BeamDir = application:get_env(web_server,tmp_dir,[]),
	    SuiteName = filename:rootname(filename:basename(Suite)),
	    ?DBG(SuiteName),
	    filename:join(BeamDir,SuiteName)

    end.
