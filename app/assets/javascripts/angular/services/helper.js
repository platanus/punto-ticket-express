angular.module('puntoTicketApp.services').factory('timeHelper',[ '$filter',
	function($filter) {
		// generates a new date if the event does not exist,
		// otherwise it transforms the rails date format to javascript format
		function resolveTime(start, end) {

			var startDate, endDate, startTime, endTime;
				if(!start && !end) {
					// if there are no start and end dates, taking the current time
					// var nowDate = new Date();
					// var nowTime = $filter('date')(nowDate, 'h:mm a');
					startDate = endDate = new Date();
					startTime = endTime = '12:00 AM';

				} else {
					// convert string to dates
					serverStartDate = new Date(start);
					serverEndDate = new Date(end);
					// takes only the date (for datapicker)
					startDate = new Date(serverStartDate.toDateString());
					endDate  = new Date(serverEndDate.toDateString());
					// takes only the time (for timepicker)
					startTime = $filter('date')(serverStartDate, 'h:mm a');
					endTime = $filter('date')(serverEndDate, 'h:mm a');
				}

				return {
					dates: {startDate: startDate, endDate: endDate},
					times: {startTime: startTime, endTime: endTime}
			}
		}

		// changes tamezone to GTM+00:00
		function readjustTimeZone(date) {
			date.setMinutes(date.getMinutes() - date.getTimezoneOffset());
			return date;
		}

		return {
			time : function(start, end){
				return resolveTime(start, end);
			},
			readjustTimeZone: function(date){
				return readjustTimeZone(date);
			}
		}
	}
]);