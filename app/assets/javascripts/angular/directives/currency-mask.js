angular.module('puntoTicketApp.directives')
	.directive('numberMask', ['$filter', function ($filter) {
		return {
			require: '?ngModel',

			link: function (_scope, _element, _attrs, _ngModel) {
				if (!_ngModel) return;

				// Removes non digit characters
				var cleanFormat = function(_value) {
					if(!_value) _value = 0;
					return parseInt(_value.toString().replace(/[^0-9]+/g,''));
				};

				var setMask = function() {
					$(_element).priceFormat({
						prefix: '',
						centsSeparator: ',',
						thousandsSeparator: '.',
						centsLimit: 0
					});
				};

				var applyNumberFormat = function(_value) {
					_value = cleanFormat(_value).toString();

					var formattedNumber = [],
						digits = _value.split(''),
						separatorIdx = digits.length - 3;

					for(var i = digits.length - 1; i >= 0; i--) {
						formattedNumber.push(digits[i]);
						if(separatorIdx == i && i != 0) {
							separatorIdx -= 3;
							formattedNumber.push('.');
						}
					}

					return formattedNumber.reverse().join('');
				};

				// This is triggered when user interacts with text input
				// Transform input (view) value from 999.999.999 to model value 999999999
				_ngModel.$parsers.unshift(function (_value) {
					return cleanFormat(_value);
				});

				// This is triggered when model value is setted without user interaction.
				// For example: on edit when value comes from server side.
				// Transform model value from 999999999 to view value 999.999.999
				_ngModel.$formatters.unshift(function(_value) {
					return applyNumberFormat(_value);
				});

				setMask();
			}
		};
	}]);