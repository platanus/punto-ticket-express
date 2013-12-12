angular.module('puntoTicketApp.filters')
	// Extracts an ngModel current validation status and returns an error message if invalid.
	.filter('modelError', ['$inflector', function($inflector) {
		return function(_model) {
			if(_model === undefined || _model.$valid) return null;
			var msg;
			angular.forEach(_model.$error, function(k, v) {
				if(k && !msg) {
					//msg = $i10n('error.invalid.' + $inflector.parameterize(v, '_')); // just keep the first message for now.
					msg = 'error.invalid.' + $inflector.parameterize(v, '_');
				}
			});
			return msg;
		};
	}]);
