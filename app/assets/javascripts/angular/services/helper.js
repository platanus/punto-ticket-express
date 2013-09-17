angular.module('puntoTicketApp.services').factory('defineTime',[ '$filter',
	function($filter) {
		// generates a new date if the event does not exist,
		// otherwise it transforms the rails date format to javascript format
		function resolveTime(start, end) {

			var startDate, endDate, startTime, endTime;
  			if(!start && !end) {
    			// if there are no start and end dates, taking the current time
    			// var nowDate = new Date();
    			// var nowTime = $filter('date')(nowDate, 'h:mm a');
    			startDate = endDate = startTime = endTime = '';

  			} else {
    			// convert string to dates
    			startDate = new Date(start);
    			endDate  = new Date(end);
    			startTime = $filter('date')(startDate, 'h:mm a');
    			endTime = $filter('date')(endDate, 'h:mm a');
  			}

  			return {
    			dates: {startDate: startDate, endDate: endDate},
    			times: {startTime: startTime, endTime: endTime}
			}
		}

		return {
			time : function(start, end){
				return resolveTime(start, end);
			}
    	}
		return resolveTime();
	}
]);