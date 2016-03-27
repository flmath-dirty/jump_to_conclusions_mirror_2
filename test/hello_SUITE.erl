%%%-------------------------------------------------------------------
%%% File     : hello_SUITE.erl
%%% ct_run -pa . -dir test 
%%%-------------------------------------------------------------------

-module(hello_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").

all() -> 
    [my_test_case].
    

my_test_case(_Config) -> 
	 ct:pal("Hello Test!~n").
