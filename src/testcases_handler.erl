%% @doc Testcases handler.
-module(testcases_handler).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([charsets_accepted/2]).

-export([from_json/2]).
-include("message_templates.hrl").

%%-define(TEST,1).
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
	PreJsonList = [
		    [{<<"path">>,re:replace(Path,"/","%2F",[global, {return,binary}])},
		     {<<"tc">>, atom_to_binary(Tc,utf8)},
		     {<<"active">>,false}] || {Path,Tc}<- ListOfPathTcTuples],
	?DBG(PreJsonList),
	TcJson = jsx:encode(PreJsonList),
	?DBG(TcJson),
	Response = <<"{\"data\" : ",TcJson/bitstring,"}">>,
	?DBG(Response),	
%	cowboy_req:reply(200, [
%		{<<"content-type">>, <<"text/plain; charset=utf-8">>}
%	], [Response], Req2)
	{true,cowboy_req:set_resp_body(Response,Req2),State};
	        _ ->
	    {true, Req, State}
    end.

selected_suites_to_list(JsonListSelectedSuites)->
	lists:foldl(fun(X, Acc)->	
	   BinaryEncodedPath = proplists:get_value(<<"path">>,X),
	   UrlStringPath = binary_to_list(BinaryEncodedPath),
	   ListPath =re:split(UrlStringPath,"%2F",[{return,list}]),
	   Path = filename:rootname(filename:join(ListPath)),
	   [Path |Acc] end,[], JsonListSelectedSuites).

fetch_pathes_and_testacases(ListOfSuitesPathes) ->
 	lists:foldl(fun(X, Acc)-> 
	     BaseName = filename:basename(X),
	    %% BeamDir = application:get_env(web_server,beam_dir,[]),	
	     BeamDir = "/home/math/proj/web_server/tmp",%%make as env variable
	     code:purge(list_to_atom(BaseName)),
	     compile:file(X,[{outdir,BeamDir}]),
	     code:load_abs(filename:join(BeamDir,BaseName)),
	     Module = list_to_atom(BaseName),
	      TcTuples = [{X,Tc} || Tc <- Module:all()],
	      lists:append(TcTuples, Acc) end, [], ListOfSuitesPathes).

