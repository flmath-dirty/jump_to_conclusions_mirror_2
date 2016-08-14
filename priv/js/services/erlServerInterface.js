app.service("ErlServerInterface", ['$http', function($http) {
    // [{"file":"supervisor_SUITE",
    // "path":"%2Fhome%2Fmath%2Fproj%2Ftest%2Fsupervisor_SUITE.erl",
    // "active":true}]}

    this.getSuites= function () {
	return	$http.get("http://localhost:8080/suites")
    }

    this.getTestcases = function(Suite){
	var SuiteWithoutActiveField = {"file" : Suite.file,
				       "path": Suite.path}
	var req_selected =  {"data" :[SuiteWithoutActiveField]}
	return $http.post("http://localhost:8080/testcases", req_selected)
    }

}])



