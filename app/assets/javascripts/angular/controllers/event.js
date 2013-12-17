//EVENTS/FORM
angular.module('puntoTicketApp.controllers')
	.controller('FormEventCtrl', ['$scope', '$window', 'DateUtils', function ($scope, $window, DateUtils) {
		var loadEventObject = function(_event) {
			$scope.event = {
				id: _event.id,
				isPublished: _event.is_published,
				name: _event.name,
				producerId: _event.producer_id,
				address: _event.address,
				sellLimit: _event.sell_limit,
				description: _event.description,
				customUrl: _event.custom_url,
				startTime: _event.start_time,
				endTime: _event.end_time,
				producer: null
			};

			$scope.tickets = _event.ticket_types;
			loadEventDates();
		};

		var loadProducersData = function(_producers) {
			$scope.producers = _producers;
			$scope.event.producer = _.findWhere($scope.producers, {id: $scope.event.producerId});
		};

		var ticketsAdded = function() {
			var result = false;

			_.each($scope.tickets, function(_ticket) {
				if(!_ticket.destroy)
					result = true;
			});

			return result;
		};

		var loadEventDates = function() {
			$scope.dates = {};

			if(!$scope.event.startTime || !$scope.event.endTime) {
				$scope.dates.startDate = DateUtils.tomorrow();
				$scope.dates.startTime = 0;
				$scope.dates.endDate = DateUtils.tomorrow();
				$scope.dates.endTime = 3600;

			} else {
				$scope.dates.startDate = DateUtils.toDate($scope.event.startTime);
				$scope.dates.startTime = DateUtils.timePartToSecs($scope.event.startTime);
				$scope.dates.endDate = DateUtils.toDate($scope.event.endTime);
				$scope.dates.endTime = DateUtils.timePartToSecs($scope.event.endTime);
			}
		};

		var buildStartDatetime = function() {
			if(!$scope.dates.startDate || !$scope.dates.startTime)
				$scope.dates.startDateTime = null;
			$scope.dates.startDateTime = DateUtils.toRailsDate(
				DateUtils.addSeconds($scope.dates.startDate, $scope.dates.startTime));
		};

		var buildEndDatetime = function() {
			if(!$scope.dates.endDateTime || !$scope.dates.endTime)
				$scope.dates.endDateTime = null;
			$scope.dates.endDateTime = DateUtils.toRailsDate(
				DateUtils.addSeconds($scope.dates.endDate, $scope.dates.endTime));
		};

		var watchEventDates = function() {
			$scope.$watch('dates.startDate', function(_newValue, _oldValue) {
				buildStartDatetime();
			});

			$scope.$watch('dates.startTime', function(_newValue, _oldValue) {
				buildStartDatetime();
			});

			$scope.$watch('dates.endDate', function(_newValue, _oldValue) {
				buildEndDatetime();
			});

			$scope.$watch('dates.endTime', function(_newValue, _oldValue) {
				buildEndDatetime();
			});
		};

		var watchFormDirty = function() {
			$scope.$watch('form.$dirty', function(_newValue, _oldValue) {
				$scope.isEventDataModified = _newValue;
			});
		};

		var initFeeData = function(_event) {
			$scope.fee = {include: _event.include_fee};
			initTicketPrices();
			watchFeeInclude();
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

			if(!$scope.event.isPublished && !$scope.event.id) {
				$scope.$watch('leavePageReason', function(_newValue, _oldValue) {
					if(_newValue !== 'formSubmit') {
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
			initFeeData(_event);
			watchSubmitAction();
			watchEventDates();
			$scope.isPastEvent = _isPastEvent;
			$scope.disabled = ($scope.producers.length == 0);
		};

		$scope.onStartDateChange = function() {
			$scope.dates.endDate = $scope.dates.startDate;
		};

		$scope.addTicket = function() {
			$scope.tickets.push({name:"", price:"", quantity:0});
		};

		$scope.deleteTicket = function(index) {
			if($scope.tickets[index].id) {
				$scope.tickets[index]["destroy"] = "1";
			} else {
				$scope.tickets.splice(index,1);
			}
		};

		$scope.onSaveButtonClick = function(_event) {
			if(!ticketsAdded()) {
				_event.preventDefault();
				$scope.notTicketsModal = true;
				return;
			}

			$scope.leavePageReason = 'formSubmit';
		};

		$scope.closeNoTicketsModal = function() {
			$scope.notTicketsModal = false;
		};

		var initTicketPrices = function() {
			if($scope.fee.include) {
				var fixedFee = $scope.event.producer ? $scope.event.producer.fixed_fee : 0;
				var percentFee = $scope.event.producer ? $scope.event.producer.percent_fee : 0;

				_.each($scope.tickets, function(_ticket) {
					_ticket.price -= fixedFee;
					_ticket.price -= Math.round(_ticket.price * percentFee / (percentFee + 100));
				});
			}
		};

		// set calculated ticket price depending on producer fees and ticket price before fee
		$scope.calculateTicketPrice = function(_ticket) {
			if($scope.fee.include) {
				var fixedFee = $scope.event.producer ? $scope.event.producer.fixed_fee : 0;
				var percentFee = $scope.event.producer ? $scope.event.producer.percent_fee : 0;
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

// EVENTS/INDEX
angular.module('puntoTicketApp.controllers')
	.controller('MyEventsCtrl', ['$scope', function ($scope) {

		$scope.navType = 'pills';
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

			if($scope.event.producer && !$scope.event.producer.confirmed) {
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
			$scope.event.producer = _eventProducer;
			$scope.isPastEvent = _isPastEvent;
		};
	}
]);

//EVENTS/PROMOTIONS
angular.module('puntoTicketApp.controllers')
	.controller('EventNestedResourceCtrl', ['$scope', function ($scope) {
		$scope.init = function(_eventProducer, _isPastEvent) {
			$scope.event.producer = _eventProducer;
			$scope.isPastEvent = _isPastEvent;
		};
	}
]);
