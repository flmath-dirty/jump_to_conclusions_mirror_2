%%%-------------------------------------------------------------------
%%% File     : server_SUITE.erl
%%%-------------------------------------------------------------------
%%%
%%% ct_run -pa . -dir test 
%%%
%%%-------------------------------------------------------------------

-module(server_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").

all() -> 
    [my_test_case_1, my_test_case_2].


my_test_case_1(_Config) -> 
ct:pal("my_test_case_1 run"),
ok.
	
my_test_case_2(_Config) ->
ct:pal("my_test_case_2 run"), 
ok.
	
other_start() ->
ct:pal("other_tc run"),
ok.
