angular.module('puntoTicketApp.filters').filter('pteCurrency',
    [ '$filter', '$locale', function(filter, locale) {
      var currencyFilter = filter('currency');
      var formats = locale.NUMBER_FORMATS;
      return function(amount, currencySymbol) {
        var value = currencyFilter(amount, currencySymbol);
        var sep = value.indexOf(formats.DECIMAL_SEP);
        var result = null;

        if(amount == undefined) return;

        if(amount >= 0) {
          result = value.substring(0, sep);

        } else {
					result = value.substring(0, sep) + ')';
        }

				return result.replace(/\,/g,'.');
      };
    } ]);
