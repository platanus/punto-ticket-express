/**
 * Simple localization service/filter.
 *
 * Configuring:
 * * Register new full/partial locales using `$i10nProvider.register`
 * * Set preferred locale stack using `$i10nProvider.setLocalePrefs`
 *
 * Usage in modules:
 *    inject(['$i10n', function($i10n) {
 *      var translatedString = $i10n('keyString');
 *    });
 *
 * Usage in templates:
 *    <span>{{ 'a-string-key' | i10n }}</span>
 *
 * @author Ignacio Baixas <ignacio@platan.us>
 */

(function() {
	'use strict';

	var LANG = {}, PREFS = ['en'];

	// Hash precompile function
	function precompile(_target, _r, _path) {
		var group, k;
		for(k in _target) {
			group = _path ? _path + '.' + k : k;
			if(typeof _target[k] == 'string') _r[group] = _target[k];
			else precompile(_target[k], _r, group);
		}
	}

	// Translate logic
	function translate(_key) {
		var ns, r, i , j;
		for(i = 0; (ns = PREFS[i]); i++) {
			if((r = LANG[ns + '.' + _key]) !== undefined) {
				for(j = 1; j < arguments.length; j++) {
					r = r.replace('$' + j, arguments[j]);
				}
				return r;
			}
		}
		return 'string not found: ' + _key; // better fallback please
	}

	angular.module('puntoTicketApp.directives')
		.run(function() {
			var temp = {};
			precompile(LANG, temp);
			LANG = temp;
		})
		// The provider will allow service configuration
		.provider('$i10n', function() {
			'use strict';

			return {
				// TODO: improve this
				register: function(_langTree) {
					angular.extend(LANG, _langTree);
				},
				setLocalePrefs: function(_prefs) {
					PREFS = _prefs;
				},
				$get: function() {
					return translate;
				}
			};
		})
		// Provide service as filter too
		.filter('i10n', function() {
			return translate;
		});
})();
