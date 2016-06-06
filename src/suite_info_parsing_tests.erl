-module(suite_info_parsing_tests).

-define(TEST,1).
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-compile([export_all]).
-define(DBG(Message),io:format("Module: ~p, Line:~p, :~p~n",[?MODULE ,?LINE, Message])).
-else.
-define(NOTEST, 1).
-define(DBG(Message),true).
-endif.

get_group_inline_test()->
    Inputs = 
	[
	 {gr1,[some_option_1],[my_test_case_1,{inline_2,[], [my_test_case_2]}]},
	 {gr2,[],[my_test_case_2,{inline_3,[],[my_test_case_3,{inline_4,[],[my_test_case_4]}]}]},
	 {gr3,[],[my_test_case_3,{group, gr4}]},
	 {gr4,[],[my_test_case_4]}
	],
    Outputs = suite_info_parsing:get_groups_inline(Inputs),
    ?assertMatch( 
       Outputs,
       [
	{gr4,
	 %%  {gr4,[],[my_test_case_4]}
	 {[{[gr4],my_test_case_4}],
	  %%no group references
	  []}},
	%%{gr3,[],[my_test_case_3,...]},
	{gr3,
	 {[{[gr3],my_test_case_3}],
	  %% {gr3,[],[{group, gr4}]}
	  [{[gr3],gr4}]}},
	{gr2,
	 %% {gr2,[],[..,{inline_3,[],[...,{inline_4,[],[my_test_case_4]}]}]},
	 {[{[inline_4,inline_3,gr2],my_test_case_4},
	   %% {gr2,[],[...,{inline_3,[],[my_test_case_3]}]},
	   {[inline_3,gr2],my_test_case_3},
	   %%{gr2,[],[my_test_case_2,...]}
	   {[gr2],my_test_case_2}],
	  %% no group references
	  []}},
	{gr1,
	 %% {gr1,[...],[...,{inline_2,[], [my_test_case_2]}]},
	 {[{[inline_2,gr1],my_test_case_2},
	   %% {gr1,[...],[my_test_case_1,...]},
	   {[gr1],my_test_case_1}],
	  %%no group references
	  []}}]).
get_group_group_ref_test()->   
    Inputs = 
	[
	 {gr1,[some_option_1],[{group, gr2}]},
	 {gr2,[],[{group, gr3},{group, gr4}]},
	 {gr3,[some_option_2],[{group, gr4}]},
	 {gr4,[],[my_test_case_1]}
	],
    Outputs=suite_info_parsing:get_groups_inline(Inputs),
    ?assertMatch(
       Outputs,
       [{gr4,{[{[gr4],my_test_case_1}],[]}},
	{gr3,{[],[{[gr3],gr4}]}},
	{gr2,{[],[{[gr2],gr3},{[gr2],gr4}]}},
	{gr1,{[],[{[gr1],gr2}]}}]).
get_group_group_no_cycle_test()->
    Inputs = 
	[
	 {gr2,[],[{group, gr3},{group, gr4}]},
	 {gr3,[some_option_2],[{group, gr4}]},
	 {gr1,[some_option_1],[{group, gr2}]},
	 {gr4,[],[my_test_case_1]}
	],
    A=suite_info_parsing:get_groups_inline(Inputs),
    Outputs = suite_info_parsing:get_topological_sorted_group_ref_dag(A), 
    ?assertMatch( Outputs, [gr1,gr2,gr3,gr4]).
get_group_group_cycle_test()->
        Inputs = 
	[
	 {gr2,[],[{group, gr3},{group, gr4}]},
	 {gr3,[some_option_2],[{group, gr4}]},
	 {gr1,[some_option_1],[{group, gr2}]},
	 {gr4,[],[my_test_case_1,{group, gr1}]},
	 {gr5,[],[my_test_case_1]}
	],
    A=suite_info_parsing:get_groups_inline(Inputs),
    Outputs  = suite_info_parsing:get_topological_sorted_group_ref_dag(A),
    ?assertMatch(Outputs, {cycle,[gr3,gr4,gr1,gr2]}).

get_flat_groups_test()->
        Inputs = 
	[
	 {gr2,[],[{group, gr3},{group, gr4}]},
	 {gr3,[some_option_2],[{group, gr4}]},
	 {gr1,[some_option_1],[{group, gr2}]},
	 {gr4,[],[my_test_case_1]}
	],
    suite_info_parsing:make_groups_flat(Inputs).
get_flat_groups_2_test()->
        Inputs = 
	[
	 {gr1,[],[{group, gr2}]},
	 {gr2,[],[{group, gr3}]},
	 {gr3,[],[{group, gr4}]},
	 {gr4,[],[my_test_case_1]}
	],
    Outputs = [{gr1,[{[gr4,gr3,gr2,gr1],my_test_case_1}]},
	       {gr2,[{[gr4,gr3,gr2],my_test_case_1}]},
	       {gr3,[{[gr4,gr3],my_test_case_1}]},
	       {gr4,[{[gr4],my_test_case_1}]}],
    ?assertMatch(Outputs, suite_info_parsing:make_groups_flat(Inputs)).
get_flat_groups_3_test()->
        Inputs = 
	[
	 {gr1,[],[{group, gr2}]},
	 {gr2,[],[{gr3,[],[{group, gr4}]}]},
	 {gr4,[],[my_test_case_1]}
	],
    Outputs = [{gr1,[{[gr4,gr3,gr2,gr1],my_test_case_1}]},
	       {gr2,[{[gr4,gr3,gr2],my_test_case_1}]},
	       {gr4,[{[gr4],my_test_case_1}]}],
   ?assertMatch(Outputs, suite_info_parsing:make_groups_flat(Inputs)).%    get_groups_inline(Inputs).

get_flat_groups_4_test()->
        Inputs = 
	[
	 {gr1,[],[{group, gr2}]},
	 {gr2,[],[{group, gr4},{group, gr3}]},
	 {gr3,[],[{group, gr4}]},
	 {gr4,[],[my_test_case_4]}
	],
    Outputs = 
	[{gr1,[{[gr4,gr2,gr1],my_test_case_4},
	       {[gr4,gr3,gr2,gr1],my_test_case_4}]},
	 {gr2,[{[gr4,gr3,gr2],my_test_case_4},
	       {[gr4,gr2],my_test_case_4}]},
	 {gr3,[{[gr4,gr3],my_test_case_4}]},
	 {gr4,[{[gr4],my_test_case_4}]}],
    ?assertMatch(Outputs, suite_info_parsing:make_groups_flat(Inputs)).

get_flat_groups_5_test()->
    Inputs = 
	[
	 {gr1,[],[{group, gr2},my_test_case_1]},
	 {gr2,[],[{group, gr4},my_test_case_2]},
	 {gr3,[],[{group, gr4},my_test_case_3]},
	 {gr4,[],[my_test_case_4]}
	],
    Outputs =[{gr1,[{[gr1],my_test_case_1},
		    {[gr4,gr2,gr1],my_test_case_4},
		    {[gr2,gr1],my_test_case_2}]},
	      {gr2,[{[gr2],my_test_case_2},{[gr4,gr2],my_test_case_4}]},
	      {gr3,[{[gr3],my_test_case_3},{[gr4,gr3],my_test_case_4}]},
	      {gr4,[{[gr4],my_test_case_4}]}],
    ?assertMatch(Outputs, suite_info_parsing:make_groups_flat(Inputs)).
get_flat_groups_6_test()->
    Inputs = 
	[
	 {gr1,[],[{group, gr2},my_test_case_1]},
	 {gr2,[],[{group, gr4},my_test_case_2]},
	 {gr3,[],[{group, gr4},my_test_case_3]},
	 {gr4,[],[my_test_case_4]}
	],
    Outputs =
	[
	 {gr1,[
	       {[gr1],my_test_case_1},
	       {[gr4,gr2,gr1],my_test_case_4},
	       {[gr2,gr1],my_test_case_2}]},
	 {gr2,[{[gr2],my_test_case_2},{[gr4,gr2],my_test_case_4}]},
	 {gr3,[{[gr3],my_test_case_3},{[gr4,gr3],my_test_case_4}]},
	 {gr4,[{[gr4],my_test_case_4}]}],
    ?assertMatch(Outputs, suite_info_parsing:make_groups_flat(Inputs)).

get_all_inline_1_test()->
    Inputs = 
	[my_test_case_1, {group, gr12}, my_test_case_2, 
	 {group, gr34} , my_test_case_3, my_test_case_4, 
	 {group, gr24}],
    Outputs =
	[{'$no_group',{[{['$no_group'],my_test_case_1},
			{['$no_group'],my_test_case_2},
			{['$no_group'],my_test_case_3},
			{['$no_group'],my_test_case_4}],
		       [{['$no_group'],gr12},
			{['$no_group'],gr34},
			{['$no_group'],gr24}]}}],

    ?assertMatch(Outputs,  suite_info_parsing:get_all_inline(Inputs,[])).

get_all_inline_2_test()->
    InputsAll = 
	[my_test_case_1,%%testcase
	 {group, gr1}, %% reference to simple group
	 {gr2,[some_option],[my_test_case_3, my_test_case_4]}],%% inline group

    InputsGroups =  [{gr1,[],[my_test_case_2]},
		     {gr21,[some_option_1],[{gr22,[some_option_2],[my_test_case_2, my_test_case_1]}]},
		     {gr12,[],[my_test_case_5, my_test_case_6]}],
    Outputs = [{gr12,{[{[gr12],my_test_case_5},{[gr12],my_test_case_6}],
		      []}},
	       {gr21,{[{[gr22,gr21],my_test_case_2},
		       {[gr22,gr21],my_test_case_1}],
		      []}},
	       {gr1,{[{[gr1],my_test_case_2}],[]}},
	       {'$no_group',{[{[gr2,'$no_group'],my_test_case_3},
			      {[gr2,'$no_group'],my_test_case_4},
			      {['$no_group'],my_test_case_1}],
			     [{['$no_group'],gr1}]}}],
    ?assertMatch(Outputs,  suite_info_parsing:get_all_inline(InputsAll,InputsGroups)).



get_all_inline_3_test()->
    InputsAll = 
	[my_test_case_1,%%testcase
	 {group, gr1}, %% reference to simple group
	 {gr2,[some_option],[my_test_case_3, my_test_case_4]}],%% inline group

    InputsGroups =  
	[
	 {gr21,[some_option_1],[{gr22,[some_option_2],[my_test_case_2, my_test_case_1]}]},
	 {gr12,[],[my_test_case_5, my_test_case_6]}],      
    Outputs =
	[{gr12,{[{[gr12],my_test_case_5},{[gr12],my_test_case_6}],
		[]}},
	 {gr21,{[{[gr22,gr21],my_test_case_2},
		 {[gr22,gr21],my_test_case_1}],
		[]}},
	 {'$no_group',{[{[gr2,'$no_group'],my_test_case_3},
			{[gr2,'$no_group'],my_test_case_4},
			{['$no_group'],my_test_case_1}],
		       [{['$no_group'],gr1}]}}],
    ?assertMatch(Outputs,  suite_info_parsing:get_all_inline(InputsAll,InputsGroups)).


get_all_flat_1_test()->
    InputsAll = 
	[my_test_case_1,%%testcase
	 {group, gr1}, %% reference to simple group
	 {gr2,[some_option],[my_test_case_3, my_test_case_4]}],%% inline group

    InputsGroups =  
	[{gr1,[],[my_test_case_2]},
	 {gr21,[some_option_1],[{gr22,[some_option_2],[my_test_case_2, my_test_case_1]}]},
	 {gr12,[],[my_test_case_5, my_test_case_6]}],
    Outputs =
	[{gr12,[{[gr12],my_test_case_5},{[gr12],my_test_case_6}]},
	 {'$no_group',[{[gr2,'$no_group'],my_test_case_3},
		       {[gr2,'$no_group'],my_test_case_4},
		       {['$no_group'],my_test_case_1},
		       {[gr1,'$no_group'],my_test_case_2}]},
	 {gr21,[{[gr22,gr21],my_test_case_2},
		{[gr22,gr21],my_test_case_1}]},
	 {gr1,[{[gr1],my_test_case_2}]}],
    ?assertMatch(Outputs, suite_info_parsing:make_all_flat(InputsAll,InputsGroups)).



get_group_flat_adv_1_test()->

    Inputs = [
	      {gr1,[],[my_test_case_1]},
	      {gr21,[some_option_1],[{gr22,[some_option_2],[my_test_case_2, my_test_case_1]}]},
	      {gr12,[],[my_test_case_5, my_test_case_6]},
	      {gr32,[],[my_test_case_3, {group, gr24}]},
	      {gr24,[],[my_test_case_2, my_test_case_4]}
	     ],   
    Outputs =
	[{gr12,[{[gr12],my_test_case_5},{[gr12],my_test_case_6}]},
	 {gr21,[{[gr22,gr21],my_test_case_2},
		{[gr22,gr21],my_test_case_1}]},
	 {gr1,[{[gr1],my_test_case_1}]},
	 {gr32,[{[gr32],my_test_case_3},
		{[gr24,gr32],my_test_case_4},
		{[gr24,gr32],my_test_case_2}]},
	 {gr24,[{[gr24],my_test_case_2},{[gr24],my_test_case_4}]}],
    ?assertMatch(Outputs, suite_info_parsing:make_groups_flat(Inputs)).


get_all_flat_adv_1_test()->
    InputsAll = 
	[my_test_case_1,%%testcase
	 {group, gr1}, %% reference to simple group
	 {gr2,[some_option],[my_test_case_3, my_test_case_4]},%% inline group
	 {group, gr21},%% reference with group with inline group inside
	 {gr3,[],[my_test_case_2, {group,gr12}]},%%
	 {group,gr32}%% group with tc and reference to group
	],
    InputsGroups =  
	[
	 {gr1,[],[my_test_case_1]},
	 {gr21,[some_option_1],[{gr22,[some_option_2],[my_test_case_2, my_test_case_1]}]},
	 {gr12,[],[my_test_case_5, my_test_case_6]},
	 {gr32,[],[my_test_case_3, {group, gr24}]},
	 {gr24,[],[my_test_case_2, my_test_case_4]}
	],
    Outputs =
	[{'$no_group',[{[gr2,gr3,'$no_group'],my_test_case_3},
		       {[gr2,gr3,'$no_group'],my_test_case_4},
		       {[gr3,'$no_group'],my_test_case_2},
		       {['$no_group'],my_test_case_1},
		       {[gr24,gr32,'$no_group'],my_test_case_2},
		       {[gr24,gr32,'$no_group'],my_test_case_4},
		       {[gr32,'$no_group'],my_test_case_3},
		       {[gr22,gr21,'$no_group'],my_test_case_1},
		       {[gr22,gr21,'$no_group'],my_test_case_2},
		       {[gr1,'$no_group'],my_test_case_1},
		       {[gr12,gr3,'$no_group'],my_test_case_6},
		       {[gr12,gr3,'$no_group'],my_test_case_5}]},
	 {gr12,[{[gr12],my_test_case_5},{[gr12],my_test_case_6}]},
	 {gr21,[{[gr22,gr21],my_test_case_2},
		{[gr22,gr21],my_test_case_1}]},
	 {gr1,[{[gr1],my_test_case_1}]},
	 {gr32,[{[gr32],my_test_case_3},
		{[gr24,gr32],my_test_case_4},
		{[gr24,gr32],my_test_case_2}]},
	 {gr24,[{[gr24],my_test_case_2},{[gr24],my_test_case_4}]}],

   ?assertMatch(Outputs, suite_info_parsing:make_all_flat(InputsAll,InputsGroups)).

