angular.module('puntoTicketApp.directives')
	.directive('pteTimePicker', function() {
		var SECONDS_STEP = 1800; //30 minutes
		var TOTAL_SECS_DAY = 86400; //24 hours,

		return {
			template:
				'<select ng-options="time | pteTime for time in times"></select>',

			restrict: 'E',
			replace: true,
			transclude: true,
			require: 'ngModel',

			link: function(_scope, _element, _attrs, _ngModel) {
				_scope.times = [];

				var loadSelectOptions = function() {
					for(var i = 0; i < TOTAL_SECS_DAY; i += SECONDS_STEP) {
						_scope.times.push(i);
					}
				};

				var setSeconds = function(_seconds) {
					for(var i = 0; i < TOTAL_SECS_DAY; i += SECONDS_STEP) {
						var from = i;
						var to = i + SECONDS_STEP;
						if(_seconds >= from && _seconds < to) {
							if(_seconds >= (to - SECONDS_STEP / 2))
								return to;
							else
								return from;
						}
					}

					return 0;
				};

				loadSelectOptions();

				_ngModel.$formatters.unshift(function(_modelValue) {
					_ngModel.$setViewValue(_modelValue);
					return setSeconds(_modelValue);
				});

				_ngModel.$parsers.push(function(_viewValue) {
					return setSeconds(_viewValue);
				});
			}
		};
	})
