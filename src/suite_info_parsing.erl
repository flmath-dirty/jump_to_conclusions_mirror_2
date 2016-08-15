-module(suite_info_parsing).

-export([get_groups_inline/1, make_groups_flat/1]).
-export([]).

%%-define(TEST,1).
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-compile([export_all]).
-define(DBG(Message),io:format("Module: ~p, Line:~p, :~p~n",[?MODULE ,?LINE, Message])).
-else.
-define(NOTEST, 1).
-define(DBG(Message),true).
-endif.

%% To parse all() function when we already know groups() we adding {'$root_group',[],all()}
%% mechainizm is the same 
get_all_inline(All, Groups)->
    get_groups_inline([{'$root_group',[],All}|Groups]).

make_all_flat(All, Groups)->
    make_groups_flat([{'$root_group',[],All}|Groups]).

%% solving groups
get_groups_inline(Groups)->
    get_groups_inline(Groups,[]).
   
get_groups_inline([H|Groups], Acc)->
    Processed = get_group_inline(H), 
    get_groups_inline(Groups, [Processed|Acc]);
get_groups_inline([],Acc) ->
    Acc.

%% First step, dived main group into Testcases, Groups by reference and Inline groups
%% Returns {Tcs,GrpRefs} where 
%% Tcs = [{Path,TcName}]
%% GrpRefs = [{Path, GrpRef}]
%% Path = [Group1,..., GroupN] where testcase prosition is GroupN. ... .Group1.TcName
%% or
%% Path = [Group1,..., GroupN] where prosition is GroupN. ... .Group1.GrpRef to later expansion
%% it means GroupN is the most external

get_group_inline({GroupName,_Options,List}) ->
    {Tcs,GrpRefs,InlineGrps} = divide_list(List),
    PathTcList = add_path_to_tc([GroupName],Tcs),
    PathGrpRefList = add_path_to_grp_ref([GroupName],GrpRefs),
    
    get_group_inline([GroupName],[],PathTcList,PathGrpRefList,InlineGrps,GroupName).

%% If there is Inline Group divded it recurently 
get_group_inline(Path,[],Tcs,GrpRefs,[{InlGrpName,_Opt, InlineList}|InlineGrps],TopGroup)->
   
    {LocTcs,LocGrpRefs,LocInlineGrps}=divide_list(InlineList),
    PathTcList = add_path_to_tc([InlGrpName|Path],LocTcs),
    PathGrpRefList = add_path_to_grp_ref([InlGrpName|Path], LocGrpRefs),
    get_group_inline([InlGrpName|Path],[],
		     lists:append(PathTcList,Tcs),
		     lists:append(PathGrpRefList,GrpRefs),
		     lists:append(LocInlineGrps,InlineGrps),TopGroup);

get_group_inline(_Path,[],Tcs,GrpRefs,[],TopGroup)->
    {TopGroup,{Tcs,GrpRefs}}.


divide_list(List)->
    divide_list(List,[],[],[]).
divide_list([H|List],Tcs,GrpRefs,InlineGrps)->
    
    case H of
	{group,Grp}-> 
	    divide_list(List,Tcs,[Grp|GrpRefs],InlineGrps);
	{InlGrpName,_Opt, InlineList} ->
	    divide_list(List,Tcs,GrpRefs,
			[{InlGrpName,_Opt, InlineList}|InlineGrps]);
	A when is_atom(A) ->
	    divide_list(List,[A|Tcs],GrpRefs,InlineGrps)
    end;
divide_list([],Tcs,GrpRefs,InlineGrps) ->
        {Tcs,GrpRefs,InlineGrps}.


%% Transform groups to form:
%% [{GroupName,[{TestcasePathAsList,TestcaseName}]}]
%% called from get_groups_inline/1-2 so Groups() == [] not supported
make_groups_flat(Groups)->
    GroupsInline=get_groups_inline(Groups),

    TopologicalOrder = get_topological_sorted_group_ref_dag(GroupsInline),
    expand_groups_refs(GroupsInline,TopologicalOrder).

expand_groups_refs(GroupsInline,TopologicalOrder)->
    [LeafGroup|RestGroupsOrder] = lists:reverse(TopologicalOrder),
   %% length(GroupsInline)==length(TopologicalOrder),
  
    {ListOfTcs, []} = proplists:get_value(LeafGroup,GroupsInline),
    RestGroupsInline = proplists:delete(LeafGroup,GroupsInline),
    
    expand_groups_refs(RestGroupsInline, [{LeafGroup,ListOfTcs}], RestGroupsOrder).


expand_groups_refs(GroupsInline, ProcessedGroups,  [HeadGroup|RestGroupsOrder])->

    {ListOfTcs, ListOfGroupsRefs} = proplists:get_value(HeadGroup,GroupsInline),
    ResolvedReferences = resolve_references(ListOfGroupsRefs,ProcessedGroups),
    RestGroupsInline = proplists:delete(HeadGroup,GroupsInline),
    expand_groups_refs(RestGroupsInline, 
		       [{HeadGroup,lists:append(ListOfTcs,ResolvedReferences)}|ProcessedGroups],
		       RestGroupsOrder);
expand_groups_refs([], ProcessedGroups,  []) ->
    ProcessedGroups.

resolve_references(ListOfGroupsRefs,ProcessedGroups)->
    resolve_references(ListOfGroupsRefs,ProcessedGroups,[]).  
resolve_references([{Path,GrpName}|ListOfGroupsRefs],ProcessedGroups,Acc)->
    %% UpdatePath=[GrpName|Path],
    ListOfTcs = proplists:get_value(GrpName,ProcessedGroups),
    ExtListOfTcs = extend_path_to_tc(Path,ListOfTcs),
    resolve_references(ListOfGroupsRefs,
		       ProcessedGroups,
		       lists:append(ExtListOfTcs,Acc));
resolve_references([],_ProcessedGroups,Acc) -> 
			  Acc.


%% Manipulators to groups path as lists
add_path_to_grp_ref(Path,GrpRefs)->
    add_path_to_grp_ref(Path,GrpRefs,[]).
add_path_to_grp_ref(Path,[H|GrpRefs],Acc)->
    add_path_to_grp_ref(Path,GrpRefs,[{Path,H}|Acc]);
add_path_to_grp_ref(_Path,[],Acc) ->
    Acc.


add_path_to_tc(Path,Tcs)->
    add_path_to_tc(Path,Tcs,[]).  
add_path_to_tc(Path,[H|Tcs],Acc)->
    add_path_to_tc(Path,Tcs,[{Path,H}|Acc]);
add_path_to_tc(_Path,[],Acc) ->
    Acc.

extend_path_to_tc(Path,Tcs)->
    extend_path_to_tc(Path,Tcs,[]).  
extend_path_to_tc(Path,[{LocalPath, H}|Tcs],Acc)->
    extend_path_to_tc(Path,Tcs,[{lists:append(LocalPath,Path),H}|Acc]);
extend_path_to_tc(_Path,[],Acc) ->
    Acc. 


%% Creation of DAG of groups dependecies to get topological sorting
get_topological_sorted_group_ref_dag(InlinedGroups)->
    Digraph= digraph:new([acyclic]),
    get_topological_sorted_group_ref_dag(InlinedGroups,Digraph).

get_topological_sorted_group_ref_dag(_InlinedGroups,{cycle,Cycle})->
    {cycle,Cycle};
get_topological_sorted_group_ref_dag([{From,{_TCs,GroupRefList}}|InlinedGroups],Digraph)->
    digraph:add_vertex(Digraph,From),
    DigraphOrCycle = add_edges(Digraph,From,GroupRefList),
    get_topological_sorted_group_ref_dag(InlinedGroups,DigraphOrCycle);
get_topological_sorted_group_ref_dag([],Digraph) ->
    digraph_utils:topsort(Digraph).

add_edges(Digraph,From,[{_Path,To}|GroupRefList])->
    Result =case digraph:add_edge(Digraph,From,To) of
		{error,{bad_vertex,To}} ->
		    digraph:add_vertex(Digraph,To),
		    digraph:add_edge(Digraph,From,To),
		    GroupRefList;
		{error,{bad_edge,Cycle}} ->
		    {cycle,Cycle};
		_ -> GroupRefList
	    end,
    add_edges(Digraph,From,Result);
add_edges(_Digraph,_From,{cycle,Cycle}) ->
    {cycle,Cycle};
add_edges(Digraph,_From,[]) ->
    Digraph.

