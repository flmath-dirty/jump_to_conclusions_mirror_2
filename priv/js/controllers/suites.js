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
	var req_selected =  {"data" :[Suite]}
	$http.post("http://localhost:8080/testcases", req_selected)
	    .success(function(response,status)
		     { 
			 var tmp_testcases = []
			 angular.forEach( response.data, function(s){
			     var tmp_tc = {}
			     var swap_ext = {"swapActive" : false}
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



/*
  app.controller("OptionsPanel", function($scope, $http) {
  
  this.get_option = function(option_key){
  console.log(option_key)
  var req_option =  {"data" : option_key}
  $http.post("http://localhost:8080/options", req_option)
  .success(function(response,status)
  {$scope.option_value = response.data;})
  .error(function(response,status)
  {console.log(response);})
  console.log($scope.option_value)
  return $scope.option;
  }
  // $scope.option_value= this.get_option('full_testlog_index')
  })

  app.controller("LogsPanel", function($scope, $window) {
  
  $window.onpopstate = function(event) {
  console.log("location: ");
  };
  
  $window.onpushstate = function(event) {
  console.log("location: ");
  };
  
  this.history_forward = function(){
  log_frame_name.history.forward()
  }


  this.history_back = function(){
  log_frame_name.history.back()
  }

  })

  app.config(function($routeProvider) {
  $routeProvider
  .when("/", {
  templateUrl : "logs/all_runs.html"
  });
  });
  log_frame_name.addEventListener('popstate', function(event) {
  if (event.state) {
  console.log("location: ");
  }
  }, false);

  onpopstate = function(event) {
  console.log("location: ");
  };
  
  onpushstate = function(event) {
  console.log("location: ");
  };
*/

app.controller("LogsPanel", function($scope) {
    //this.iframe = document.getElementById("log_path").contentWindow.history


    $scope.log_location = "logs/all_runs.html" 
    $scope.history_queue_back = []
    $scope.history_queue_forward = []
    $scope.check_onload_loop = false


    this.get_path_log = function(){
	return $scope.log_location;
    }
    


    $(log_path).on('load', function(event) {
	if($scope.check_onload_loop === true){
	    //console.log("location: "+  $(log_path).context.contentWindow.document.documentURI)
	    $scope.history_queue_back.push($scope.log_location)
	    $scope.log_location = $(log_path).context.contentWindow.document.documentURI
	    $scope.history_queue_forward = []
	    //console.log("back "+$scope.history_queue_back)
	    //console.log("forward "+$scope.history_queue_forward)
	    
	}else{
	    //console.log("set check_onload_loop on")
	    $scope.check_onload_loop = true
	}
    });
    

    this.history_forward = function(){
	//log_frame_name.history.forward()
	if($scope.history_queue_forward.length>0){
	    $scope.history_queue_back.push($scope.log_location)
	    $scope.check_onload_loop = false //omit next onload
	    $scope.log_location = $scope.history_queue_forward.pop()
	    $(log_path).context.src = $scope.log_location
	}
	//console.log("forward pushed ")
	//console.log("back "+$scope.history_queue_back)
	//console.log("forward "+$scope.history_queue_forward)
    }
    
    this.history_back = function(){
	//log_frame_name.history.back()
	//console.log("back pushed " + $scope.history_queue_back.length)
	
	if($scope.history_queue_back.length>0){
	    //console.log("back pushed and executed")
	    $scope.history_queue_forward.push($scope.log_location)
	    $scope.check_onload_loop = false //omit next onload
	    $scope.log_location = $scope.history_queue_back.pop()
	    $(log_path).context.src = $scope.log_location
	    //$(log_path).context.src
	    
	}
	// console.log("back "+$scope.history_queue_back)
	// console.log("forward "+$scope.history_queue_forward)
    }
    this.history_home = function(){
	//$scope.history_queue_back.push("logs/all_runs.html")
	$scope.check_onload_loop = false //omit next onload
	$scope.history_queue_back.push($scope.log_location)
	$scope.log_location = "logs/all_runs.html"
	$scope.history_queue_forward = []
	$(log_path).context.src = $scope.log_location
	//console.log("history home pushed ")
	//console.log("back "+$scope.history_queue_back)
	//console.log("forward "+$scope.history_queue_forward)
    }
    
})
