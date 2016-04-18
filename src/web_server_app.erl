%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(web_server_app).
-behaviour(application).

-include("message_templates.hrl").

%-define(TEST,1).
-ifdef(TEST).
-define(DBG(Message),io:format("Module:~p, Line:~p, :~p~n",[?MODULE ,?LINE, Message])).
-else.
-define(DBG(Message),true).
-endif.

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->
    Dispatch = 
	cowboy_router:compile(
	  [{'_', [ {"/testcases", testcases_handler, []},
		   {"/suites", suites_handler, []},
 		   {"/run_tc", run_handler, []},
		   {"/", cowboy_static, 
		    {file, "priv/index.html"}},
		   {"/[...]", cowboy_static, 
		    {dir, "priv", [{mimetypes, cow_mimetypes, all}]}
		   }
		 ]
	   }
	  ]),
    ?DBG("Started"),
    
    jtc_tc_db = ets:new(jtc_tc_db,[bag,{keypos,#testcase.path},named_table,public]),
    jtc_suites_db = ets:new(jtc_suites_db,[set,{keypos,#suites.path},named_table,public]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 8080}], 
				[{env, [{dispatch, Dispatch}]}
				]),
    web_server_sup:start_link().

stop(_State) ->
    ok.
