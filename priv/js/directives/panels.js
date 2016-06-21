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

app.directive('suiteTestcasePanel',function(){
    return{
	restrict: 'E',
	templateUrl: 'html/suite-testcase-panel.html'
    };
})
