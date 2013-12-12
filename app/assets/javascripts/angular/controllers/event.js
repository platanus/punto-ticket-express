//EVENTS/FORM
angular.module('puntoTicketApp.controllers')
	.controller('FormEventCtrl', ['$scope', '$window', function ($scope, $window) {
		var loadEventObject = function(_event) {
			$scope.event = {
				id: _event.id,
				isPublished: _event.is_published,
				name: _event.name,
				producerId: _event.producer_id,
				address: _event.address,
				sellLimit: _event.sell_limit,
				description: _event.description,
				customUrl: _event.custom_url
			}

			$scope.tickets = _event.ticket_types;
		};

		var loadProducersData = function(_producers) {
			$scope.producers = _producers;
			$scope.producer = _.findWhere($scope.producers, {id: $scope.event.producerId});
		};

		var watchFormDirty = function() {
			$scope.$watch('form.$dirty', function(_newValue, _oldValue) {
				$scope.isEventDataModified = _newValue;
			});
		};

		var watchFeeInclude = function() {
			// watch include fee property
			$scope.$watch('fee.include', function() {
				// toggle to include fee in ticket price
				if($scope.fee.include) {
					_.each($scope.tickets, function(_ticket) {
						_ticket.priceBeforeFee = _ticket.price;
						$scope.calculateTicketPrice(_ticket);
					});
				}
				// toggle to normal mode
				else {
					_.each($scope.tickets, function(_ticket) {
						 _ticket.price = _ticket.priceBeforeFee || _ticket.price;
					});
				}
			});
		};

		var watchSubmitAction = function() {
			$scope.leavePageReason = undefined;

			if(!$scope.isPublished && !$scope.event.id) {
				$scope.$watch('leavePageReason', function(newValue, oldValue) {
					if(newValue !== 'formSubmit') {
						$window.onbeforeunload = function(){
							return 'Esta apunto de abandonar esta pagina sin haber guardado sus datos.';
						};

					} else {
						$window.onbeforeunload = undefined;
					}
				});
			}
		};

		$scope.init = function(_event, _producers, _isPastEvent) {
			loadEventObject(_event);
			loadProducersData(_producers);
			watchFormDirty();
			watchFeeInclude();
			watchSubmitAction();
			$scope.fee = {include: false};
			$scope.isPastEvent = _isPastEvent;
			$scope.disabled = ($scope.producers.length == 0);
		};

		$scope.addTicket = function() {
			$scope.tickets.push({name:"", price:"", quantity:0});
		};

		$scope.deleteTicket = function(index) {
			$scope.tickets[index]["destroy"] = "1";
		};

		$scope.onSaveButtonClick = function() {
			$scope.leavePageReason = 'formSubmit';
		};

		// set calculated ticket price depending on producer fees and ticket price before fee
		$scope.calculateTicketPrice = function(_ticket) {
			if($scope.fee.include) {
				var fixedFee = $scope.producer ? $scope.producer.fixed_fee : 0;
				var percentFee = $scope.producer ? $scope.producer.percent_fee : 0;
				_ticket.price = Math.round(fixedFee + _ticket.priceBeforeFee * (1 + percentFee / 100));
			}
		};

		// re-calculate all ticket prices
		$scope.calculateAllTicketPrices = function() {
			_.each($scope.tickets, function(_ticket) {
				$scope.calculateTicketPrice(_ticket);
			});
		};
	}
]);

// EVENTS/SHOW
angular.module('puntoTicketApp.controllers')
	.controller('EventShowCtrl', ['$scope', function ($scope) {
		$scope.themes = [];
		$scope.ticketTypes = [];
		// initialization tasks to be executed before the template enters execution mode
		// used to ruby data parsed into a JavaScript object

		$scope.init = function(ticketTypes, isPreview, ticketsLimit, themes, currentTheme) {
			// eliminates unnecessary attributes
			var sumPrice = 0;
			var sumPromoPrice = 0;
			_.each(ticketTypes, function(ticketType){
				sumPrice += parseInt(ticketType.price);
				sumPromoPrice += parseInt(ticketType.promotion_price);
				// set default select option
				ticketType.bought_quantity = 0;
				// rremove attrs
				delete ticketType.created_at;
				delete ticketType.updated_at;
			});

			$scope.anyPromo = ((sumPrice - sumPromoPrice) != 0);

			$scope.isPreview = isPreview;
			$scope.ticketTypes = ticketTypes;
			$scope.ticketsLimit = ticketsLimit;

			$scope.themes = themes;
			$scope.theme = currentTheme;
		};

		$scope.closeBuyModal = function() {
			$scope.buyModal = false;
		};

		$scope.closeLimitModal = function() {
			$scope.limitModal = false;
		};

		$scope.closeNoTicketsModal = function() {
			$scope.notTicketsModal = false;
		};

		$scope.stockEmpty = function(ticketType) {
			return (ticketType.stock == 0);
		};

		$scope.typeWithPromo = function(ticketType) {
			return (ticketType.promotion_price != ticketType.price);
		};

		$scope.changeStyle = function(theme) {
			document.getElementById('theme_css').href = theme.url;
			$scope.theme = theme.name;
		};

		var buyLimitExceeded = function() {
			var totalQty = 0;
			angular.forEach($scope.ticketTypes, function(ticketType){
				totalQty += parseInt(ticketType.bought_quantity);
			});

			return (totalQty > $scope.ticketsLimit);
		};

		// removes and validates the fields of the array before being sent to the next page
		$scope.validateTicketTypes = function($event) {

			// removes all ticket_types that have no amount
			var ticketTypes = _.filter($scope.ticketTypes, function(t){
				return (t.bought_quantity && t.bought_quantity > 0);
			});

			if($scope.isPreview) {
				$event.preventDefault();
				$scope.buyModal = true;

			} else if(_.size(ticketTypes) == 0) {
				$event.preventDefault();
				$scope.notTicketsModal = true;

			} else if(buyLimitExceeded()) {
				$event.preventDefault();
				$scope.limitModal = true;
			}
		};
	}
]);

//EVENTS/EDIT_TOP_NAVBAR
angular.module('puntoTicketApp.controllers')
	.controller('EventEditTopNavbarCtrl', ['$scope', function ($scope) {
		$scope.onPublishEventClick = function(_event) {
			if($scope.isEventDataModified) {
				_event.preventDefault();
				$scope.modifiedEventDataModal = true;
				return;
			}

			if($scope.isPastEvent) {
				_event.preventDefault();
				$scope.pastEventModal = true;
				return;
			}

			if($scope.producer && !$scope.producer.confirmed) {
				_event.preventDefault();
				$scope.producerModal = true;
				return;
			}
		};

		$scope.closeProducerModal = function() {
			$scope.producerModal = false;
		};

		$scope.closePastEventModal = function() {
			$scope.pastEventModal = false;
		};

		$scope.closeModifiedEventDataModal = function() {
			$scope.modifiedEventDataModal = false;
		};
	}
]);

//EVENTS/PROMOTIONS
angular.module('puntoTicketApp.controllers')
	.controller('EventPromotionsCtrl', ['$scope', function ($scope) {
		$scope.init = function(_eventProducer, _isPastEvent) {
			$scope.producer = _eventProducer;
			$scope.isPastEvent = _isPastEvent;
		};
	}
]);

//EVENTS/PROMOTIONS
angular.module('puntoTicketApp.controllers')
	.controller('EventNestedResourceCtrl', ['$scope', function ($scope) {
		$scope.init = function(_eventProducer, _isPastEvent) {
			$scope.producer = _eventProducer;
			$scope.isPastEvent = _isPastEvent;
		};
	}
]);
