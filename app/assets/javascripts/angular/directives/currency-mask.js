angular.module('puntoTicketApp.directives')
	.directive('numberMask', ['$filter', function ($filter) {
		return {
			require: '?ngModel',

			link: function (_scope, _element, _attrs, _ngModel) {
				if (!_ngModel) return;

				var cleanFormat = function(_value) {
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

				// Sets mask after value is setted on input.
				_scope.$watch('ngModel', function() {
					setMask();
				});

				_ngModel.$parsers.unshift(function (_value) {
					return cleanFormat(_value);
				});
			}
		};
	}]);