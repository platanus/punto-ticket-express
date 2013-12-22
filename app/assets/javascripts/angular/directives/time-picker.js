angular.module('puntoTicketApp.directives')
	.directive('pteTimePicker', function() {
		var SECONDS_STEP = 1800; //30 minutes
		var TOTAL_SECS_DAY = 86400; //24 hours,

		html = '<select style="width: 102px;">';
		for(var i = 0; i < TOTAL_SECS_DAY; i += SECONDS_STEP)
			html += '<option value=' + i + '>{{' + i + ' | pteTime}}</option>';
		html += '</select>';

		return {
			template: html,
			restrict: 'E',
			replace: true,
			require: 'ngModel',
			link: function(_scope, _element, _attrs, _ngModel) {

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

				_ngModel.$formatters.unshift(function(_modelValue) {
					return setSeconds(_modelValue);
				});
			}
		};
	});
