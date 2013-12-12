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
