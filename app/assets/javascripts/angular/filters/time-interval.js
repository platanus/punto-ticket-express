// serializes an javascript object so it can be sent through to a url and concatenated with a url
angular.module('puntoTicketApp.filters').filter('timeInterval', function() {
	return function(input, min, max) {
				min = parseInt(min); //Make string input int
				max = parseInt(max);
				for (var i=min; i<max; i++) {

					h = i <= 12 ? i : i - 12;
					if(h == 0) h = 12;
					dd = i < 12 ? 'AM' : 'PM'

					input.push(h + ':00 ' + dd);
					input.push(h + ':30 ' + dd);
				}
				return input;
			};
		})