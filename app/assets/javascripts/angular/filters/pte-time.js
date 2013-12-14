angular.module('puntoTicketApp.filters').filter('pteTime', function() {
	return function(_seconds) {
		var hours = _seconds / 3600;
		var parts = hours.toString().split('.');
		var hour = parts[0];
		var minutes = 0;
		var a = "AM";
		if(hour >= 12) a = "PM";
		if(hour == 0) {
			hour = 12;
		} else if (hour > 12) {
			hour -= 12;
		}
		if(parts.length > 1) minutes = parts[1] / 10 * 60;
		hour = hour.toString();
		if(hour.length == 1) hour = "0" + hour;
		minutes = minutes.toString();
		if(minutes.length == 1) minutes = "0" + minutes;
		return hour.toString() + ":" + minutes.toString() + " " + a;
	};
})