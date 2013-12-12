angular.module('puntoTicketApp.directives')
	.directive('bsControlGroup', ['$compile', function($compile) {
		return {
			restrict: 'AE',
			controller: function($scope) {
				return {
					setLabel: function(_contents) { $scope.label = _contents; },
					setHelp: function(_contents) { $scope.help = _contents; },
					setError: function(_contents) { $scope.error = _contents; }
				};
			},
			template:
				'<div class="control-group" ng-class="{ \'error\': !!error }">\
					<label class="control-label" for="{{for}}"></label>\
					<div class="controls">\
						<span ng-transclude></span>\
						<span ng-if="help && !error" class="help-inline">{{help}}</span>\
						<span ng-if="error" class="help-inline">{{error}}</span>\
					</div>\
				</div>',
			replace: true,
			transclude: true,
			scope: {
				error: '@',
				help: '@'
			},
			link: function(_scope, _element, _attrs) {
				_attrs.$observe('label', function(_value) {
					if(_value !== undefined) {
						_scope.label = _value;
					}
				});

				_scope.$watch('label', function(_label) {
					var label = _element.find('label');
					label.html(_label);
					$compile(label.contents())(_scope.$parent);
				});
			}
		};
	}])
	.directive('bsCgLabel', function() {
		return {
			restrict: 'AE',
			require: '^bsControlGroup',
			link: {
				pre: function(_scope, _element, _attrs, _group) {
					_group.setLabel(_element.html());
					_element.remove();
				}
			}
		};
	});
