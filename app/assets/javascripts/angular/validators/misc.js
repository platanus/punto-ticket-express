(function(angular, undefined) {

function compare(_value, _other, _criteria) {
	switch(_criteria) {
		case 'L': return _value < _other;
		case 'LE': return _value <= _other;
		case 'E': return _value == _other;
		case 'GE': return _value >= _other;
		case 'G': return _value > _other;
		default: return false;
	}
}

angular.module('puntoTicketApp.validators')
	.factory('UrlValidator', function() {
		var regexp = /^[a-z0-9]+$/;
		return function(_value) {
			return (!_value || _value.search(regexp) != -1);
		};
	})
	.factory('DateGreaterThanTodayValidator', [ 'DateUtils', function(DateUtils) {
		return function(_date) {
			return (_date > DateUtils.today());
		};
	}])
	.factory('DateCompareValidator', function() {
		return function(_date, _other, _criteria) {
			if(!_date || !_other) return true;
			return compare(_date, _other, _criteria);
		};
	})
  .factory('PromoConfigValidator', function() {
    return function(_config, _promotionType) {
      if(!_promotionType) return true;
      if(_promotionType.id == 'nx1' && _config < 2) return false;
      if(_promotionType.id == 'percent_discount' && (_config <= 0 || _config > 100)) return false;
      if(_promotionType.id == 'amount_discount' && _config <= 0) return false;
      return true;
    };
  })
	.factory('TimeCompareValidator', function(DateUtils) {
		return function(_time, _otherTime, _date, _otherDate, _criteria) {
			_time = parseInt(_time);
			_otherTime = parseInt(_otherTime);
			if(!moment(_date).isSame(moment(_otherDate), 'day')) return true;
			return compare(_time, _otherTime, _criteria);
		};
	});
})(angular);
