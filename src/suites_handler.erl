%% @doc Suites handler.
-module(suites_handler).

-export([init/2]).
-export([content_types_provided/2]).
-export([list_to_json/2]).

-include("message_templates.hrl").

%%-define(TEST,1).
-ifdef(TEST).
-define(DBG(Message),io:format("Module:~p, Line:~p, :~p~n",[?MODULE ,?LINE, Message])).
-else.
-define(DBG(Message),true).
-endif.

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    {[
      {<<"application/json">>, list_to_json}
     ], Req, State}.

list_to_json(Req, State) ->
    JSONlist =  suites_as_json(),
    ?DBG([[JSONlist]]),
    {[JSONlist], Req, State}.

suites_as_json()-> 
    FindSuitesCmd = application:get_env(web_server,suites,[]),
    FilesString = os:cmd(FindSuitesCmd),
    Files= string:tokens(FilesString,"\n"),
    ?DBG(Files),
    SuitesRecords = suites_paths_to_records(Files),
    ets:insert(jtc_suites_db,SuitesRecords),
    ?DBG(ets:tab2list(jtc_suites_db)),
    SuitesJsxList = suites_records_to_jsx(SuitesRecords),
    ?DBG(SuitesJsxList),     
    SuitesJSON = jsx:encode(SuitesJsxList), 
    ?DBG(SuitesJSON),
    <<"{\"data\" : ",SuitesJSON/bitstring,"}">>.


suites_paths_to_records(Files)->
    suites_paths_to_records(Files, []).
suites_paths_to_records([], Acc) ->
    Acc;
suites_paths_to_records([H|Files], Acc) ->
    Record = 
	#suites{file=filename:basename(H, ".erl"),
		path=list_to_bitstring(H),
		active=false,
		update_time = filelib:last_modified(H)},
    ?DBG(Record#suites.update_time),    
    suites_paths_to_records(Files, [Record|Acc]).

suites_records_to_jsx(Files)->
    suites_records_to_jsx(Files, []).

suites_records_to_jsx([H|List], Acc)->
   SuiteJsx =   
	[
	 {<<"file">>,list_to_bitstring(H#suites.file)},
	 {<<"path">>,H#suites.path},
	 {<<"active">>,H#suites.active}
	],
    suites_records_to_jsx(List,[SuiteJsx|Acc]);
suites_records_to_jsx([],Acc) ->
   Acc.

%%% head and tail recursion I need to decide which is better, It would be good to test it

%%suites_records_to_jsx([H|List])->
%%    SuiteJsx =   
%%	[
%%	 {<<"file">>,list_to_binary(H#suites.file)},
%%	 {<<"path">>,re:replace(H#suites.path,"/","%2F",[global, {return,binary}])},
%%	 {<<"active">>,H#suites.active}
%%	],
%%    [SuiteJsx|suites_records_to_jsx(List)];
%%suites_records_to_jsx([]) ->
%%    [].











