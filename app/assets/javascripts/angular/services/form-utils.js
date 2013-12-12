angular.module('puntoTicketApp.services')
	.factory('FormUtils', function () {
		var forEach = angular.forEach,
			utils = {
				// forces a model to its dirty status
				forceModelDirty: function(_model) {
					_model.$setViewValue(_model.$viewValue);
				},
				// sets a model value as if set by the user
				setModelAsUser: function(_model, _value) {
					_model.$setViewValue(_value);
					_model.$render();
				},
				// fills a form fields as set by the user
				fillFormAsUser: function(_form, _data) {
					forEach(_data, function(v, k) {
						var model = _form[k];
						if(model && model.$setViewValue) utils.setModelAsUser(model, v);
					});
				}
			};

		return utils;
	});

