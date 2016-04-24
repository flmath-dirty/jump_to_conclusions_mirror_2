app.controller("SuitesPanel", function($scope, $http) {
    $http.get("http://localhost:8080/suites")
	.success(function(response) {$scope.suites = response;});
    //		  [{"file":"supervisor_SUITE",
    //		    "path":"%2Fhome%2Fmath%2Fproj%2Ftest%2Fsupervisor_SUITE.erl",
    //		    "active":true}]}
    
    this.toggleActive = function(s){
	s.active = !s.active;
	var list = [];
	angular.forEach( $scope.suites.data, function(s){
	    if(s.active){list.push(s);}
	});
	this.selectedSuites = list
	$scope.testcases = this.get_testcases()
	return list
    };
    this.total = function(){
	var total = 0;
	angular.forEach( $scope.suites.data, function(s){
	    if(s.active){
		total+= 1;}
	});
	return total;
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
    
    this.get_testcases = function(){
	var req_selected =  {"data" : this.selectedSuites}
	$http.post("http://localhost:8080/testcases", req_selected)
	    .success(function(response,status)
		     {$scope.testcases = response; 
		     })
	    .error(function(response,status)
		   {console.log(response);});
	return $scope.testcases;}
})


app.controller("TestcasePanel", function($scope, $http) {
    $scope.selectedTc = []
    
    this.toggleActive = function(s){
	s.active = !s.active;
	var list = [];
	angular.forEach($scope.testcases.data, function(s){
	    if(s.active){list.push(s);}
	});

	$scope.selectedTc = list
	return list;
    };
    this.isActive = function(s){
	return s.active;
    };


    this.run_testcases = function(){
	var req_selected =  {"data" : $scope.selectedTc}
	$http.post("http://localhost:8080/run_tc", req_selected)
	    .success(function(response,status)
		     {$scope.is_run_ok = response;})
	    .error(function(response,status)
		   {console.log(response);});
	return $scope.testcases;}

})

app.directive('suitesPanel',function(){
    return{
	restrict: 'E',
	controller: 'SuitesPanel',
	controllerAs: 'sPanel',
	templateUrl: 'html/suites-panel.html'
    };
})
app.directive('testcasePanel',function(){
    return{
	restrict: 'E',
	controller: 'TestcasePanel',
	controllerAs: 'tcPanel',
	templateUrl: 'html/testcase-panel.html'
    };
})
