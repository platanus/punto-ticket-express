angular.module('puntoTicketApp.services')
	// Various date manipulation functions
	.factory('DateUtils', function () {

		var utils = {
			today: function() {
        var now = moment();
				return moment().startOf('day').toDate();
			},
      tomorrow: function() {
        return moment().startOf('day').add('days', 1).toDate();
      },
      timePartToSecs: function(_date) {
        var date = moment(_date).local();
        return date.hours() * 3600 + date.minutes() * 60;
      },
      toDate: function(_date) {
        return moment(_date).local().startOf('day').toDate();
      }
		};

		return utils;
	});
