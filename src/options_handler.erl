%% @doc Optionss handler.
-module(options_handler).
 
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([charsets_accepted/2]).

-export([from_json/2]).
-include("message_templates.hrl").

%-define(TEST,1).
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-compile([export_all]).
-define(DBG(Message),io:format("Module: ~p, Line:~p, :~p~n",[?MODULE ,?LINE, Message])).
-else.
-define(NOTEST, 1).
-define(DBG(Message),true).
-endif.

init(Req, Opts) ->
    _Headers = cowboy_req:headers(Req),
    %%_Headers = cowboy_req:meta(media_type,Req),
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
    try cowboy_req:method(Req) of
	<<"POST">> ->
	    ?DBG(["POST received"]), 
	    ?DBG(["Request options"]),
	    {ok,ReqBody,Req2} = cowboy_req:body(Req),
	    [{<<"data">>,Option}] = jsx:decode(ReqBody),	
	    ?DBG(Option),
	    OptionValue = application:get_env(web_server,binary_to_atom(Option,utf8),""), 
	    ?DBG(OptionValue),
	    OptionValueJson = jsx:encode(list_to_binary(OptionValue)),
	 
	    Response = <<"{\"data\" : ", OptionValueJson/bitstring,"}">>,
	    %% ?DBG(Response),	
	    {true,cowboy_req:set_resp_body(Response,Req2),State};
	_ ->
	    {true, Req, State}
    catch
	ErrorClass:Error -> 
	    error_logger:error_msg(
	      "Error in POST testcases processing ~p: ~p ~n", [ErrorClass,Error]),
	     {true, Req, State}
    end.

   









