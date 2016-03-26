%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
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
    SuitesRecord = lists:map(fun(X)->#suites{
	        file=list_to_binary(filename:basename(X, ".erl")),
		path=re:replace(X,"/","%2F",[global, {return,binary}]),
		active=false} end, Files),
    SuitesBinaryList = suites_to_json(SuitesRecord),
    ?DBG(SuitesBinaryList),     
    SuitesJSON = jsx:encode(SuitesBinaryList), 
 ?DBG(SuitesJSON),
 <<"{\"data\" : ",SuitesJSON/bitstring,"}">>.


suites_to_json(List)->
	RecordList=record_info(fields,suites),
	?DBG(["suites_to_json ",RecordList]),
	records_to_json(RecordList,List,[]).

records_to_json(_RecordList,[],Acc)->
	Acc;
records_to_json(RecordList,[Head|Tail],Acc)->
	?DBG(["records_to_json ",Head]),	
	[_|Values] = tuple_to_list(Head),
	?DBG(["records_to_json ",Values]),
	Translated=lists:zipwith(
		fun(X,Y)->{list_to_binary(atom_to_list(X)),Y} end, 
				RecordList, Values),
	[Translated|records_to_json(RecordList,Tail,Acc)].
