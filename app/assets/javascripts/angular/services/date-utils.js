angular.module('puntoTicketApp.services')
	// Various date manipulation functions
	.factory('DateUtils', function () {

    var gmtOffset = (new Date()).getTimezoneOffset();

		var utils = {
			today: function() {
				var now = moment();
				return moment().startOf('day').toDate();
			},
			tomorrow: function(_date) {
				var m = moment();
				if(_date) m = moment(_date);
				return m.startOf('day').add('days', 1).toDate();
			},
			timePartToSecs: function(_date) {
				var date = moment(_date).local();
				return date.hours() * 3600 + date.minutes() * 60;
			},
			toDate: function(_date) {
				return moment(_date).local().startOf('day').toDate();
			},
			addSeconds: function(_date, _seconds) {
				return moment(_date).startOf('day').add('seconds', _seconds);
			},
			toRailsDate: function(_moment) {
				return _moment.local().format('YYYY-MM-DD HH:mm:ss ZZ');
			},
      adjustDatepickerOffsetBug: function(_date) {
        return moment(_date).add('minutes', gmtOffset).toDate();
      }
		};

		return utils;
	});
