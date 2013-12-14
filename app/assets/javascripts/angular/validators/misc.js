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
	.factory('DateCompareValidator', ['DateUtils', function(DateUtils) {
		return function(_date, _other, _criteria) {
			console.log("entro aca?", _date, _other);
			if(!_date || !_other) return true;
			console.log("date", _date);
			console.log("other", _other);

			switch(_criteria) {
			case 'L': return _date < _other;
			case 'LE': return _date <= _other;
			case 'E': return _date == _other;
			case 'GE': return _date >= _other;
			case 'G': return _date > _other;
			default: return false;
			}
		};
	}]);
