angular.module('puntoTicketApp.directives')
	.directive('pteRmTicketTypeButton', function() {
		return {
			template:
				'<div>\
					<input name="event[ticket_types_attributes][{{index}}][status]"\
						type="text" value="{{status}}" style="display: none;" ng-if="!(status == null)"/>\
					<input name="event[ticket_types_attributes][{{index}}][_destroy]"\
						type="text" value="{{destroy}}" style="display: none;" ng-if="!(destroy == null)"/>\
					<button ng-click="changeStatus($event)" style="width: 40px; height: 30px;" class="btn"><i class="icon-remove"></i></button>\
				</div>',

			restrict: 'E',
			transclude: true,
			replace: true,
			scope: {
				type: '='
			},

			link: function(_scope, _element, _attrs) {
				var ACTIVE = 1, DISABLED = 0, DESTROY = 1;
				_scope.status = null;
				_scope.destroy = null;

				var setInitValues = function() {
					var status = parseInt(_scope.type.status);
					_scope.index = _scope.type.index;
					setValues(status);
				};

				var setValues = function(_status) {
					var t = _scope.type;
					var hasTickets = (t.hasTickets && t.hasTickets.toString() == 'true');
					var hasId = (t.id && t.id != null && t.id != undefined);

					_scope.status = _status;
					if(_status == ACTIVE)	_scope.destroy = null;
					if(_status == DISABLED) {
						_scope.destroy = DESTROY;
						if(hasTickets) _scope.destroy = null;
					}

					if(_status == DISABLED) {
						_element.parents("tr").hide();
					}
				};

				_scope.changeStatus = function(_event) {
					_event.preventDefault();
					var status = ACTIVE;
					if(_scope.status == ACTIVE) status = DISABLED;
					setValues(status);
				};

				setInitValues();
			}
		};
	});
