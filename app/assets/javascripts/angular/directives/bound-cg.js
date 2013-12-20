angular.module('puntoTicketApp.directives')
	// Makes a control group error status bound to an internal input
	.directive('boundCg', ['$filter', 'FormUtils', function($filter, FormUtils) {

		var extractError = $filter('modelError');

		return {
			restrict: 'A',
			priority: -1,
			require: 'bsControlGroup',
			link: function(_scope, _element, _attrs, _group) {
				var models = [],
					inputs = _element.find('.inputs-wrapper').find('input, textarea, select');

				inputs.each(function(_idx, _input) {
					models.push($(_input).controller('ngModel'));
				});

				// bind the group's error status to the model validation errors.
				_scope.$watch(function() {
					var error = null;

					angular.forEach(models, function(_model) {
						// consider a model invalid only if invalid AND dirty.
						if(_model && _model.$invalid && _model.$dirty) {
							error = extractError(_model);
							return;
						}
					});

					return error;

				}, function(_error) {
					_group.setError(_error);
				});
			}
		};
	}]);
