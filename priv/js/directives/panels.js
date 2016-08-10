app.directive('suitesPanel',function(){
    return{
	restrict: 'E',
	controller: 'SuitesPanel',
	controllerAs: 'sPanel',
	templateUrl: 'html/suites-testcases-panel/suites-panel.html'
    };
})
app.directive('testcasesPanel',function(){
    return{
	restrict: 'E',
	controller: 'TestcasesPanel',
	controllerAs: 'tcPanel',
	templateUrl: 'html/suites-testcases-panel/testcases-panel.html'
    };
})

app.directive('suitesTestcasesPanel',function(){
    return{
	restrict: 'E',
	templateUrl: 'html/suites-testcases-panel.html'
    };
})

app.directive('swapPanel',function(){
    return{
	restrict: 'E',
	controller: 'SwapPanel',
	controllerAs: 'swapPanel',
	templateUrl: 'html/swap-panel.html'
    };
})

app.directive('swapPanelLeft',function(){
    return{
	restrict: 'E',
	templateUrl: 'html/swap-panel/swap-panel-left.html'
    };
})

app.directive('swapPanelRight',function(){
    return{
	restrict: 'E',
	templateUrl: 'html/swap-panel/swap-panel-right.html'
    };
})

app.directive('swapPanelButtons',function(){
    return{
	restrict: 'E',
	templateUrl: 'html/swap-panel/swap-panel-buttons.html'
    };
})

app.directive('runButton',function(){
    return{
	restrict: 'E',
	templateUrl: 'html/run-button.html'
    };
})
app.directive('navigationPanel',function(){
    return{
	restrict: 'E',
	templateUrl: 'html/navigation-panel.html'
    };
})
app.directive('carouselArrows',function(){
    return{
	restrict: 'E',
	templateUrl: 'html/carousel-arrows.html'
    };
})
app.directive('logPanel',function(){
    return{
	restrict: 'E',
	templateUrl: 'html/log-panel.html'
    };
})
