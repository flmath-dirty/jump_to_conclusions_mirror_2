app.controller("SwapPanel", function($scope, $http) {
    $scope.swapSelectedTc = []; 
    $scope.swapUnselectedTc = [];
    $scope.$watchGroup(['testcases.data','selectedTc'], function(){
	if(angular.isDefined($scope.testcases)){
	    //console.log("triggered SwapPanel watchGroup");
	    var swapSelectedTcTmp = [];
	    var swapUnselectedTcTmp = [];
	    angular.forEach($scope.testcases.data, function(s){
		//console.log(s);
		if(s.active){
		    swapSelectedTcTmp.push(s);} 
		else {
		    swapUnselectedTcTmp.push(s);}
	    });
	    $scope.swapSelectedTc = swapSelectedTcTmp;
	    $scope.swapUnselectedTc = swapUnselectedTcTmp;
	    //console.log($scope.swapUnselectedTc);
	}
    });
    this.toggleSelected = function(s){
	s.swapActive = !s.swapActive
	return []
    };

    this.isSelected = function(s){
	return s.swapActive;
    };
    this.isActive = function(s){
	return s.active;
    };
    
    this.swapOut = function(){ 
	var list = []
   	angular.forEach($scope.testcases.data, function(s){
	    if(s.swapActive && s.active){
		s.active = false;
		s.swapActive = false;
	    }
	    list.push(s)
	})

	$scope.testcases.data = list
	this.updateSelectedTc()
	return list
    }

    this.swapIn = function(){ 
	var list = []
   	angular.forEach($scope.testcases.data, function(s){
	    if(s.swapActive && !s.active){
		s.active = true;
		s.swapActive = false;
	    }
	    list.push(s)
	})

	$scope.testcases.data = list
	this.updateSelectedTc()
	return list
    }
    this.swapBoth = function(){  
	var list = []

   	angular.forEach($scope.testcases.data, function(s){
	    if(s.swapActive){
		if(s.active){
		    s.active=false;
		    s.swapActive = false;
		}
		else {
		    s.active = true;
		    s.swapActive = false;
		}
	    }
	    list.push(s)
	})

	$scope.testcases.data = list
	this.updateSelectedTc()
	return list
    }
    this.updateSelectedTc= function(){
	var listSelected = []
	angular.forEach($scope.testcases.data, function(s){
	    if(s.active){
		contracted_s = 	{"tc" : s.tc,
				 "path" : s.path}
		listSelected.push(contracted_s)
		;}
	});
	$scope.selectedTc = listSelected
	return listSelected
    }
})



