%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(web_server_sup).
-behaviour(supervisor).


-define(TEST,1).
-ifdef(TEST).
-define(DBG(Message),io:format("Module:~p, Line:~p, :~p~n",[?MODULE ,?LINE, Message])).
-else.
-define(DBG(Message),true).
-endif.

%% API.
-export([start_link/0]).

%% supervisor.
-export([init/1]).

%% API.

-spec start_link() -> {ok, pid()}.
start_link() ->
	?DBG("Supervisor started"),
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% supervisor.

init([]) ->
	Procs = [],
	{ok, {{one_for_one, 10, 10}, Procs}}.
