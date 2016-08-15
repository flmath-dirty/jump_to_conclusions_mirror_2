app.controller("SuitesPanel", function($scope, $http, ErlServerInterface) {
    
    $scope.suites = {"data":[]}
    
    var promiseSuite = ErlServerInterface.getSuites()
    promiseSuite.success(function(response) {	
	var tmp_suites = []	  
	angular.forEach(response.data, function(s){
	    var tmp_suite = {}
	    var path_cut_index = s.path.lastIndexOf("/")
	    var root_path = s.path.substr(0,path_cut_index+1)
	    var suite_extended = {"active" : false,
				 "root_path": root_path}
	    angular.extend(tmp_suite,s,suite_extended)
	    tmp_suites.push(tmp_suite)
	});
	$scope.suites.data = tmp_suites
    })
    
    $scope.testcases =  {"data":[]}
    
    this.toggleActive = function(Suite){
	Suite.active = !Suite.active;
	if (Suite.active){
	    var promiseTestcases = ErlServerInterface.getTestcases(Suite)
	    promiseTestcases.success(function(response){  
		var tmp_testcases = []
		angular.forEach(response.data, function(s){
		    var tmp_tc = {}
		    var swap_ext = {"swapActive" : false,
				    "active" : false}
		    angular.extend(tmp_tc,s,swap_ext)
		    tmp_tc.group_path= Suite.file +":"+tmp_tc.group_path
		    tmp_testcases.push(tmp_tc)   
		});
		
		$scope.testcases.data = tmp_testcases.concat($scope.testcases.data)
	    })	     
	}
	else{ 
	    FilterFun = this.testcase_filters_generator(Suite.path)
	    $scope.testcases.data = $scope.testcases.data.filter(FilterFun) 
	}
	return  $scope.testcases
    };

    this.active_suites = function(){
	var list = [];
	angular.forEach( $scope.suites.data, function(s){
	    if(s.active){list.push(s);}
	});	
	return list;
    }
    this.isActive = function(s){
	return s.active;
    }
    
    this.testcase_filters_generator = function(SuitePath){	
	return function(Value){return !angular.equals(SuitePath, Value.path);}
    }
})
