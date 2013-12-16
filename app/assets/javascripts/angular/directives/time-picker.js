angular.module('puntoTicketApp.directives')
	.directive('pteTimePicker', function() {
		var SECONDS_STEP = 1800; //30 minutes
		var TOTAL_SECS_DAY = 86400; //24 hours,

		template = function() {
			html = '<select style="width: 102px;">';
			for(var i = 0; i < TOTAL_SECS_DAY; i += SECONDS_STEP)
				html += '<option value=' + i + '>{{' + i + ' | pteTime}}</option>';
			html += '</select>';
			return html;
		}

		return {
			template: template(),
			restrict: 'E',
			replace: true,
			require: 'ngModel'
		};
	})
