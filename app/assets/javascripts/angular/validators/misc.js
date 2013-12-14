angular.module('puntoTicketApp.validators')
	.factory('UrlValidator', function() {
		var regexp = /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/;
		return function(_value) {
			return (!_value || _value.search(regexp) != -1);
		};
	})
  .factory('DateGreaterThanTodayValidator', [ 'DateUtils', function(DateUtils) {
    return function(_date) {
      return (_date > DateUtils.today());
    };
  }])
