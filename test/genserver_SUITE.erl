%%%-------------------------------------------------------------------
%%% File     : genserver_SUITE.erl

-module(genserver_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").

all() -> 
    [white_box_tests, black_box_tests].

white_box_tests(_Config) -> 

	ct:log("white_box_test start~n"),
ok.
	
black_box_tests(_Config) -> 

	ct:log("black_box_test: start"),
ok.
	

