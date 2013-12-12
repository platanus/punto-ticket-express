//EVENTS/FORM
angular.module('puntoTicketApp.controllers')
	.controller('FormEventCtrl', ['$scope', function ($scope) {
		$scope.$watch('includeFeeInPrice', function() {
			$scope.calculateAllTicketPrices();
		});

		var loadEventObject = function(_event) {
			$scope.event = {};
			$scope.event.name = _event.name;
			$scope.event.producerId = _event.producer_id;
			$scope.event.address = _event.address;
			$scope.event.sellLimit = _event.sell_limit;
			$scope.event.description = _event.description;
			$scope.event.customUrl = _event.custom_url;
			$scope.event.includeFee = _event.include_fee;

			$scope.tickets = _event.ticket_types;
		};

		var loadProducersData = function(_producers) {
			$scope.producers = _producers;
			$scope.producer = _.findWhere($scope.producers, {id: $scope.event.producerId});
		};

		$scope.init = function(_event, _producers, _isPastEvent) {
			loadEventObject(_event);
			loadProducersData(_producers);
			$scope.isPastEvent = _isPastEvent;
			$scope.disabled = ($scope.producers.length == 0);
			$scope.includeFeeInPrice = $scope.event.includeFee;
		};

		$scope.calculateTicketPrice = function(ticket) {
			if($scope.includeFeeInPrice) {
			var fixedFee = $scope.producer ? $scope.producer.fixed_fee : 0;
			var percentFee = $scope.producer ? $scope.producer.percent_fee : 0;

			ticket.price = Math.round(fixedFee + ticket.priceBeforeFee * (1 + percentFee / 100));
			}
		};

		$scope.calculateAllTicketPrices = function() {
			if($scope.includeFeeInPrice) {
				angular.forEach($scope.tickets, function(_ticket) {
					var fixedFee = $scope.producer ? $scope.producer.fixed_fee : 0;
					var percentFee = $scope.producer ? $scope.producer.percent_fee : 0;
					_ticket.price = Math.round(fixedFee + _ticket.priceBeforeFee * (1 + percentFee / 100));
				});
			}

			else {
				angular.forEach($scope.tickets, function(_ticket) {
					_ticket.price = _ticket.priceBeforeFee || _ticket.price;
				});
			}
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
