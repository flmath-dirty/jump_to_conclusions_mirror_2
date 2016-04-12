%% @doc Testcases handler.
-module(testcases_handler).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([charsets_accepted/2]).

-export([from_json/2]).
-include("message_templates.hrl").

%-define(TEST,1).
-ifdef(TEST).
-define(DBG(Message),io:format("Module: ~p, Line:~p, :~p~n",[?MODULE ,?LINE, Message])).
-else.
-define(DBG(Message),true).
-endif.

init(Req, Opts) ->
 _Headers = cowboy_req:headers( Req),
   %% _Headers = cowboy_req:meta(media_type,Req),
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
	    ?DBG(["Request testcases"]),
	    {ok,ReqBody,Req2} = cowboy_req:body(Req),
	    [{<<"data">>,SelectedSuites}] = jsx:decode(ReqBody),	
	    ?DBG(SelectedSuites),
	    ListOfSuites = selected_suites_to_list(SelectedSuites),
	    ListOfPathTcTuples = fetch_pathes_and_testacases(ListOfSuites),
	    ?DBG(ListOfPathTcTuples),
	    PreJsonList = tc_list_to_jsx(ListOfPathTcTuples),
	    ?DBG(PreJsonList),
	    TcJson = jsx:encode(PreJsonList),
	    ?DBG(TcJson),
	    Response = <<"{\"data\" : ",TcJson/bitstring,"}">>,
	    ?DBG(Response),	
	    {true,cowboy_req:set_resp_body(Response,Req2),State};
	_ ->
	    {true, Req, State}
    end.
tc_list_to_jsx(ListOfPathTcTuples) ->
    tc_list_to_jsx(ListOfPathTcTuples, []).

tc_list_to_jsx([{Path,Tc}|ListOfPathTcTuples], Acc) when is_atom(Tc) ->
    JsxList = 
	[{<<"path">>,re:replace(Path,"/","%2F",[global, {return,binary}])},
	 {<<"tc">>, atom_to_binary(Tc,utf8)},
	 {<<"active">>,false}],
    tc_list_to_jsx(ListOfPathTcTuples, [JsxList|Acc]);
tc_list_to_jsx([], Acc) ->
    Acc;
tc_list_to_jsx([Data|ListOfPathTcTuples], Acc) ->
    error_logger:warning_msg("Not handled test description structure ~p~n", [Data]),
    tc_list_to_jsx(ListOfPathTcTuples, Acc).


selected_suites_to_list(JsonListSelectedSuites)->
    selected_suites_to_list(JsonListSelectedSuites,[]).

selected_suites_to_list([H|JsonListSelectedSuites], Acc)->
    BinaryEncodedPath = proplists:get_value(<<"path">>,H),
    UrlStringPath = binary_to_list(BinaryEncodedPath),
    ListPath =re:split(UrlStringPath,"%2F",[{return,list}]),
    Path = filename:rootname(filename:join(ListPath)),
    selected_suites_to_list(JsonListSelectedSuites, [Path |Acc]);
selected_suites_to_list([],Acc)->
    Acc.

fetch_pathes_and_testacases(ListOfSuitesPathes) ->
    fetch_pathes_and_testacases(ListOfSuitesPathes,[]).

fetch_pathes_and_testacases([H|ListOfSuitesPathes],Acc) ->
			BaseName = filename:basename(H),
			BeamDir = application:get_env(web_server,tmp_dir,[]),	
			code:purge(list_to_atom(BaseName)),
			compile:file(H,[{outdir,BeamDir}]),
			code:load_abs(filename:join(BeamDir,BaseName)),
			Module = list_to_atom(BaseName),
			TcTuples = [{H,Tc} || Tc <- Module:all()],
    fetch_pathes_and_testacases(ListOfSuitesPathes,lists:append(TcTuples, Acc));
fetch_pathes_and_testacases([] , Acc) ->
    Acc.
