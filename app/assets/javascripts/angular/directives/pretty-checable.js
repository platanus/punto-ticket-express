angular.module('puntoTicketApp.directives').directive('prettyCheckable', function() {
    return {
        restrict: 'A',
        replace: true,
        scope: true,
        template:
           '<div class="prettyradio labelright  yellow ">'+
            '<a class="ui-icon ui-icon-shadow" ng-class="{\'checked\': value == ngModel}"> </a>'+
           '</div>',

        link: function(scope, element, attrs, controller) {
            element.bind('click', function() {
                scope.$apply(function(){
                	scope.ngModel = scope.value
                });
            });
        },
        scope: {
            value: '=value',
            title: '=title',
            ngModel: '='
        }
    }
});
