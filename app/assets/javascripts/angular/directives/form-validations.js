/*
* Example:
*
*   <input type="text" ng-focused ng-model="foo" />
*
* When the input is on focus:
*
*   1) Adds ng-focused class to the input
*   2) Toggle $focused = true from the ng-model directive
*
* When the input is not on focus:
*
*   1) Removes ng-focused class in the input
*   2) Toggle $focused = false from the ng-model directive
*
* The $focused property could be used the same way as $invalid, $pristine, etc...
*
*/
angular.module('platanus.validations', [])
  .directive('ngFocused', [function() {
    var FOCUS_CLASS = "ng-focused";

    return {
      restrict: 'A',
      require: 'ngModel',
      link: function(scope, element, attrs, ctrl) {
        ctrl.$focused = false;

        element
          // on focus
          .bind('focus', function(evt) {
            // add class
            element.addClass(FOCUS_CLASS);

            // add property
            scope.$apply(function() {ctrl.$focused = true;});
          })
          // on blur
          .bind('blur', function(evt) {
            // remove class
            element.removeClass(FOCUS_CLASS);

            // remove property
            scope.$apply(function() {ctrl.$focused = false;});
          });
      }
    };
  }]);

/*
*
* Example:
*
*   <div show-on-error="form.title">The field title is required</div>
*
* It's a simple shortcut for:
*
*   <div ng-show="!form.title.$focused && form.title.$dirty && form.title.$invalid">The field title is required</div>
*
*/
angular.module('platanus.validations')
  .directive('showOnError', [function() {
    return {
      restrict: 'A',
      scope: {
        'showOnError': '='
      },
      template: '<div ng-show="show()" ng-transclude />',
      transclude: true,
      link: function(scope, element, attrs) {
        scope.show = function() {
          return !scope.showOnError.$focused && scope.showOnError.$invalid && scope.showOnError.$dirty;
        };
      }
    };
  }]);
