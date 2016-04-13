%% @doc Suites handler.
-module(suites_handler).

-export([init/2]).
-export([content_types_provided/2]).
-export([list_to_json/2]).

-include("message_templates.hrl").

%-define(TEST,1).
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
		path=H,
		active=false},
    suites_paths_to_records(Files, [Record|Acc]).

suites_records_to_jsx(List)->
    RecordList=record_info(fields,suites),
    ?DBG(["suites_to_json ",RecordList]),
    ListWithBinValues  = jsx_values_in_suites_records(List),
    records_to_jsx(RecordList,ListWithBinValues ).


jsx_values_in_suites_records(SuitesRecords) ->
   jsx_values_in_suites_records(SuitesRecords,[]).
jsx_values_in_suites_records([], Acc) ->
    Acc;
jsx_values_in_suites_records([H|SuitesRecords], Acc) ->
    Record = 
	#suites{file=list_to_binary(H#suites.file),
		path=re:replace(H#suites.path,"/","%2F",[global, {return,binary}]),
		active=H#suites.active},
    jsx_values_in_suites_records(SuitesRecords,[Record|Acc]).


records_to_jsx(RecordList,List) ->
    records_to_jsx(RecordList,List,[]).
records_to_jsx(_RecordList,[],Acc)->
	Acc;
records_to_jsx(RecordList,[Head|Tail],Acc)->
	?DBG(["records_to_json ",Head]),	
	[_|Values] = tuple_to_list(Head),
	?DBG(["records_to_json ",Values]),
	Translated=lists:zipwith(
		fun(X,Y)->{list_to_binary(atom_to_list(X)),Y} end, 
				RecordList, Values),
	[Translated|records_to_jsx(RecordList,Tail,Acc)].










