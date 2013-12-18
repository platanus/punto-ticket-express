angular.module('puntoTicketApp.directives')
	.directive('numberMask', ['$filter', function ($filter) {
		return {
			require: '?ngModel',

			link: function (_scope, _element, _attrs, _ngModel) {
				if (!_ngModel) return;

				// Transform value from 999.999.999 to 999999999
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

				// Clean format before submit form to send clean values
				$(_element).parents('form').submit( function() {
					$(_element).val(cleanFormat($(_element).val()));
					return true;
				 });

				// Sets mask after value is setted on input.
				// This is triggered when model value is setted without user interaction.
				// For example: on edit when value comes from server side.
				_scope.$watch('ngModel', function() {
					setMask();
				});

				// Transform input (view) value from 999.999.999 to model value 999999999
				_ngModel.$parsers.unshift(function (_value) {
					return cleanFormat(_value);
				});
			}
		};
	}]);