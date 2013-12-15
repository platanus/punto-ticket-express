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
	.factory('DateCompareValidator', function(DateUtils) {
		return function(_date, _other, _criteria) {
			if(!_date || !_other) return true;

			switch(_criteria) {
			case 'L': return _date < _other;
			case 'LE': return _date <= _other;
			case 'E': return _date == _other;
			case 'GE': return _date >= _other;
			case 'G': return _date > _other;
			default: return false;
			}
		};
	})
	.factory('TimeCompareValidator', function(DateUtils) {
		return function(_time, _otherTime, _date, _otherDate, _criteria) {
			if(!moment(_date).isSame(moment(_otherDate), 'day')) return true;

			switch(_criteria) {
			case 'L': return _time < _otherTime;
			case 'LE': return _time <= _otherTime;
			case 'E': return _time == _otherTime;
			case 'GE': return _time >= _otherTime;
			case 'G': return _time > _otherTime;
			default: return false;
			}
		};
	});
