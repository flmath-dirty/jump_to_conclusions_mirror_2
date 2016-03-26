app.controller('GetSuites', function($scope, $http) {
    $scope.services =""
    $scope.selectedSuites = []
    $scope.selectedTc = []
    $scope.testcases =   {"data" : []}
    $scope.is_run_ok = ""
	//		  [{"file":"supervisor_SUITE",
	//		    "path":"%2Fhome%2Fmath%2Fproj%2Ftest%2Fsupervisor_SUITE.erl",
	//		    "active":true}]}

    $http.get("http://localhost:8080/suites")
	.success(function(response) {$scope.services = response;});
    
    $scope.toggleActive = function(s){
	s.active = !s.active;
	var list = [];
	angular.forEach($scope.services.data, function(s){
	    if(s.active){list.push(s);}
	});
	$scope.selectedSuites = list
	$scope.testcases = $scope.get_testcases()
	
    };

    $scope.toggleActiveTc = function(s){
	s.active = !s.active;
	var list = [];
	angular.forEach($scope.testcases.data, function(s){
	    if(s.active){list.push(s);}
	});

	$scope.selectedTc = list
	//$scope.testcases = $scope.get_testcases()
	
    };

    $scope.total = function(){
	var total = 0;
	angular.forEach($scope.services.data, function(s){
	    if(s.active){
		total+= 1;}
	});
	return total;
    }

    $scope.active_suites = function(){
	var list = [];
	angular.forEach($scope.services.data, function(s){
	    if(s.active){list.push(s);}
	});
	
	return list;
    }
    
    $scope.get_testcases = function(){
	var req_selected =  {"data" : $scope.selectedSuites}
	$http.post("http://localhost:8080/testcases", req_selected)
	    .success(function(response,status)
		     {$scope.testcases = response;})
	    .error(function(response,status)
		   {console.log(response);});
	return $scope.testcases;}

    $scope.run_testcases = function(){
	var req_selected =  {"data" : $scope.selectedTc}
	$http.post("http://localhost:8080/run_tc", req_selected)
	    .success(function(response,status)
		     {$scope.is_run_ok = response;})
	    .error(function(response,status)
		   {console.log(response);});
	return $scope.testcases;}
});


