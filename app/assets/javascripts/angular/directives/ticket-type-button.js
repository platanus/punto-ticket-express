angular.module('puntoTicketApp.directives')
	.directive('pteTicketTypeButton', function() {
		return {
			template:
				'<div>\
					<input name="event[ticket_types_attributes][{{index}}][status]"\
						type="text" value="{{status}}" style="display: none;" ng-if="!(status == null)"/>\
					<input name="event[ticket_types_attributes][{{index}}][_destroy]"\
						type="text" value="{{destroy}}" style="display: none;" ng-if="!(destroy == null)"/>\
					<button style="width: 110px; height: 30px;" class="btn"\
						ng-class="{\'btn-success\': hasActiveClass(),\
							\'btn-info\': hasDisabledClass(),\
							\'btn-danger\': hasDeletedClass()}"\
						ng-mouseenter="hover=true"\
						ng-mouseleave="hover=false"\
						ng-click="changeStatus($event)">\
						{{actualLabel}}\
					</button>\
				</div>',

			restrict: 'E',
			transclude: true,
			replace: true,
			scope: {
				type: '='
			},

			link: function(_scope, _element, _attrs) {
				var ACTIVE = 1, DISABLED = 0, DESTROY = 1;
				_scope.hover = false;
				_scope.status = null;
				_scope.destroy = null;

				_scope.$watch('hover', function(_actualValue, _oldValue) {
					if(_scope.hover) {
						_scope.actualLabel = _scope.hoverLabel;
					} else {
						_scope.actualLabel = _scope.btnLabel;
					}
				});

				_scope.hasActiveClass = function() {
					return (_scope.actualLabel == 'Habilitado' ||
						_scope.actualLabel == 'Habilitar');
				};

				_scope.hasDisabledClass = function() {
					return (_scope.actualLabel == 'Deshabilitado' ||
						_scope.actualLabel == 'Deshabilitar');
				};

				_scope.hasDeletedClass = function() {
					return (_scope.actualLabel == 'Borrado' ||
						_scope.actualLabel == 'Borrar');
				};

				var setInitValues = function() {
					var status = parseInt(_scope.type.status);
					_scope.index = _scope.type.index;
					setValues(status);
				};

				var setValues = function(_status) {
					var t = _scope.type;
					var hasTickets = (t.hasTickets && t.hasTickets.toString() == 'true');
					var hasId = (t.id && t.id != null && t.id != undefined);

					if(_status == ACTIVE && hasTickets && hasId) {
						_scope.btnLabel = 'Habilitado';
						_scope.hoverLabel = 'Deshabilitar';
						_scope.status = ACTIVE;
						_scope.nextStatus = DISABLED;
						_scope.destroy = null;

					} else if(_status == ACTIVE && !hasTickets && hasId) {
						_scope.btnLabel = 'Habilitado';
						_scope.hoverLabel = 'Borrar';
						_scope.status = ACTIVE;
						_scope.nextStatus = DISABLED;
						_scope.destroy = null;

					} else if(_status == ACTIVE && !hasTickets && !hasId) {
						_scope.btnLabel = 'Habilitado';
						_scope.hoverLabel = 'Borrar';
						_scope.status = ACTIVE;
						_scope.nextStatus = DISABLED;
						_scope.destroy = null;

					} else if(_status == DISABLED && hasTickets && hasId) {
						_scope.btnLabel = 'Deshabilitado';
						_scope.hoverLabel = 'Habilitar';
						_scope.status = DISABLED;
						_scope.nextStatus = ACTIVE;
						_scope.destroy = null;

					} else if(_status == DISABLED && !hasTickets && hasId) {
						_scope.btnLabel = 'Borrado';
						_scope.hoverLabel = 'Habilitar';
						_scope.status = null;
						_scope.nextStatus = ACTIVE;
						_scope.destroy = DESTROY;

					} else if(_status == DISABLED && !hasTickets && !hasId) {
						_scope.btnLabel = 'Borrado';
						_scope.hoverLabel = 'Habilitar';
						_scope.status = null;
						_scope.nextStatus = ACTIVE;
						_scope.destroy = DESTROY;

					} else {
						console.log('Unknown combination', _status, hasTickets, hasId);
					}
				};

				_scope.changeStatus = function(event) {
					event.preventDefault();
					setValues(_scope.nextStatus);
				};

				setInitValues();
			}
		};
	});
