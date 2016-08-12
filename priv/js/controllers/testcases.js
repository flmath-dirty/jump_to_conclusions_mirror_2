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
})

