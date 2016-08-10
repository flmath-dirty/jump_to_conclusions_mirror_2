app.controller("TestcasesPanel", function($scope, $http) {
    $scope.selectedTc = []
    
    this.toggleActive = function(s){
	s.active = !s.active;
	var list = [];
	angular.forEach($scope.testcases.data, function(s){
	    if(s.active){list.push(
		{"tc" : s.tc,
		 "path" : s.path});}
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
