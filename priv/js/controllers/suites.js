app.controller("SuitesPanel", function($scope, $http) {
    $http.get("http://localhost:8080/suites")
	.success(function(response) {
	    var tmp_suites = []
	    
	    angular.forEach( response.data, function(s){
		var tmp_suite = {}
		var suite_extended = {"active" : false}
		angular.extend(tmp_suite,s,suite_extended)
		tmp_suites.push(tmp_suite)
	    });
	    $scope.suites = {"data" : tmp_suites}
	});
    //		  [{"file":"supervisor_SUITE",
    //		    "path":"%2Fhome%2Fmath%2Fproj%2Ftest%2Fsupervisor_SUITE.erl",
    //		    "active":true}]}
    $scope.testcases =  {"data" : []};
    
    this.toggleActive = function(Suite){
	//console.log(Suite)
	Suite.active = !Suite.active;
	if (Suite.active){
	    this.get_testcases(Suite); 	 
	}
	else
	{
	    FilterFun = this.testcase_filters_generator(Suite.path)
	    $scope.testcases.data = $scope.testcases.data.filter(FilterFun)   
	}
	return  $scope.testcases
    };

    this.testcase_filters_generator = function(SuitePath)
    {
	return function(Value)
	{
	    return !angular.equals(SuitePath, Value.path);
	}
    }

    this.active_suites = function(){
	var list = [];
	angular.forEach( $scope.suites.data, function(s){
	    if(s.active){list.push(s);}
	});	
	return list;
    }
    this.isActive = function(s){
	return s.active;
    };
    
    this.get_testcases = function(Suite){
	var SuiteWithoutActive = {"file" : Suite.file,
				  "path": Suite.path}
	var req_selected =  {"data" :[SuiteWithoutActive]}
	$http.post("http://localhost:8080/testcases", req_selected)
	    .success(function(response,status)
		     { 
			 var tmp_testcases = []
			 angular.forEach( response.data, function(s){
			     var tmp_tc = {}
			     var swap_ext = {"swapActive" : false,
					     "active" : false}
			     angular.extend(tmp_tc,s,swap_ext)
			     tmp_testcases.push(tmp_tc)
			 });
			 $scope.testcases.data = $scope.testcases.data.concat(tmp_testcases); 
			 //console.log($scope.testcases.data)
		     })
	    .error(function(response,status)
		   {console.log(response);});
	return $scope.testcases;}

})
