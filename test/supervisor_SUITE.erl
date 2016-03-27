%%%-------------------------------------------------------------------
%%% File     : supervisor_SUITE.erl
%%%-------------------------------------------------------------------
%%%

-module(supervisor_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").

%% Mandatory list of test cases and test groups, and skip orders. 

all() -> 
    [white_box_tests, black_box_tests].


%% The test cases. The return value is irrelevant. 

white_box_tests(_Config) -> 

	ct:log("tests supervisor white: start~n"),
	ok.
	
black_box_tests(_Config) -> 

	ct:log("tests supervisor black: start~n"),
	ok.
