angular.module('puntoTicketApp.directives')
	// Makes a control group error status bound to an internal input
	.directive('boundCg', ['$filter', 'FormUtils', function($filter, FormUtils) {

		var extractError = $filter('modelError');

		return {
			restrict: 'A',
			priority: -1,
			require: 'bsControlGroup',
			link: function(_scope, _element, _attrs, _group) {

				var model = null;

				if(_attrs.boundCg) {
					// If a model is given, bind to it
					_scope.$watch(_attrs.boundCg, function(_model) {
						model = _model;
					});
				} else {
					// If no model is given, look for one in the group's contents
					var input = _element.find('input');
					if(input.length === 0) input = _element.find('textarea');
					if(input.length === 0) input = _element.find('select');
					model = input.controller('ngModel');
				}

				// bind the group's error status to the model validation errors.
				_scope.$watch(function() {
					// consider a model invalid only if invalid AND dirty.
					return model && model.$invalid && model.$dirty ? extractError(model) : null;
				}, function(_error) {
					_group.setError(_error);
				});
			}
		};
	}]);
