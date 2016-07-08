app.controller("SuitesPanel", function($scope, $http) {
    $http.get("http://localhost:8080/suites")
	.success(function(response) {$scope.suites = response;});
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
    
    this.total = function(){
	var total = 0;
	angular.forEach( $scope.suites.data, function(s){
	    if(s.active){
		total+= 1;
	    }
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
		     {
			 $scope.testcases = response; 
		     })
	    .error(function(response,status)
		   {
		       console.log(response);
		   });
	return $scope.testcases;}
    
    this.get_testcases = function(Suite){
	
	var req_selected =  {"data" :[Suite]}
	$http.post("http://localhost:8080/testcases", req_selected)
	    .success(function(response,status)
		     { 
			 var tmp_testcases = []
			 angular.forEach( response.data, function(s){
			     var tmp_tc = {}
			     var swap_ext = {"swapActive" : false}
			     angular.extend(tmp_tc,s,swap_ext),
			     tmp_testcases.push(tmp_tc)
			 });
			 $scope.testcases.data = $scope.testcases.data.concat(tmp_testcases); 
			 //console.log($scope.testcases.data)
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


    this.debugSelectedTc = function(){ 
	console.log($scope.selectedTc)
    }
    
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
	listSelected = []
	angular.forEach($scope.testcases.data, function(s){
	    if(s.active){listSelected.push(s);}
	});
	$scope.selectedTc = listSelected
	return listSelected
    }

    this.run_testcases = function(){
	var req_selected =  {"data" : $scope.selectedTc}
	$http.post("http://localhost:8080/run_tc", req_selected)
	    .success(function(response,status)
		     {$scope.is_run_ok = response;})
	    .error(function(response,status)
		   {console.log(response);});
	return $scope.testcases;}

})
