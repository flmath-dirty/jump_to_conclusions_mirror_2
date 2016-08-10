app.controller("LogsPanel", function($scope) {
    $scope.log_location = "logs/all_runs.html" 
    $scope.history_queue_back = []
    $scope.history_queue_forward = []
    $scope.check_onload_loop = false


    this.get_path_log = function(){
	return $scope.log_location;
    }


    $(log_path).on('load', function(event) {
	if($scope.check_onload_loop === true){
	    $scope.history_queue_back.push($scope.log_location)
	    $scope.log_location = $(log_path).context.contentWindow.document.documentURI
	    $scope.history_queue_forward = []
	}else{
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
    }
    
    this.history_back = function(){
	//log_frame_name.history.back()
	if($scope.history_queue_back.length>0){

	    $scope.history_queue_forward.push($scope.log_location)
	    $scope.check_onload_loop = false //omit next onload
	    $scope.log_location = $scope.history_queue_back.pop()
	    $(log_path).context.src = $scope.log_location
	    
	}
    }
    this.history_home = function(){
	//$scope.history_queue_back.push("logs/all_runs.html")
	$scope.check_onload_loop = false //omit next onload
	$scope.history_queue_back.push($scope.log_location)
	$scope.log_location = "logs/all_runs.html"
	$scope.history_queue_forward = []
	$(log_path).context.src = $scope.log_location
    }
})
