angular.module('puntoTicketApp.directives')
	// Exposes an element's ngModel as a variable in the current scope.
	.directive('ksModelAs', ['$parse', function($parse) {
		return {
			restrict: 'A',
			require: 'ngModel',
			link: function(_scope, _element, _attrs, _ctrl) {
				$parse(_attrs.ksModelAs).assign(_scope.$parent, _ctrl);
			}
		};
	}])
	// Forces a pristine input revalidation on lost focus.
	.directive('dirtyOnBlur', ['FormUtils', function(FormUtils) {
		return {
			restrict: 'AC',
			require: 'ngModel',
			link: function(_scope, _element, _attrs, _ctrl) {
				_element.on('blur', function() {
					_scope.$apply(function() {
						if(_ctrl.$pristine) FormUtils.forceModelDirty(_ctrl);
					});
				});
			}
		};
	}]);