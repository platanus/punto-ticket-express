angular.module('puntoTicketApp.filters').filter('pteTime', function() {
	return function(_seconds) {
		var hours = _seconds / 3600;
		var parts = hours.toString().split('.');
		var hour = parts[0];
		var minutes = 0;
		var a = "AM";
		if(hour >= 12) a = "PM";
		if(hour == 0) hour = 12;
		else if (hour > 12) hour -= 12;
		if(parts.length > 1) minutes = parseInt(parseFloat('0.' + parts[1])* 60);
		if(hour < 10) hour = "0" + hour.toString();
		if(minutes < 10) minutes = "0" + minutes.toString();
		return hour.toString() + ":" + minutes.toString() + " " + a;
	};
})