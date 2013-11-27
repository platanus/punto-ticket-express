// EVENTS/NEW
angular.module('puntoTicketApp.controllers')
  .controller('EventNewCtrl', ['$scope', '$filter', 'defineTime', '$window', function ($scope, $filter, defineTime, $window) {

    // all producers
    $scope.producers = [];

    // selected producer
    $scope.producer = {};

    // ticket types
    $scope.tickets = [];

    // Defines the reason for submiting the form
    // 'save' is for saving the event
    $scope.submitAction = undefined;

    // include fee in ticket price flag
    $scope.includeFeeInPrice = false;

    $scope.init = function(event, producers) {
      $scope.disabled = (producers.length == 0);
      $scope.name = event.name;
      $scope.address = event.address;
      $scope.sellLimit = event.sell_limit

      // set producers
      $scope.producers = producers;

      // define initial producer
      $scope.producer = _.findWhere(producers, { id: event.producer_id });

      // call factory
      $scope.time = defineTime.time(event.start_time, event.end_time);
      $scope.tickets = event.ticket_types;

      // it warns not to leave the form without saving data
      if(!event.is_published && !event.id)
        $scope.$watch('submitAction', function(newValue, oldValue) {
          if(newValue !== 'save' && oldValue !== 'save') {
            $window.onbeforeunload = function(){
              return 'Esta apunto de abandonar esta pagina sin haber guardado sus datos.';
            };
          }else{
            $window.onbeforeunload = undefined;
          }
        });

      // include fee property
      $scope.includeFeeInPrice = event.include_fee;
    };

    $scope.addTicket = function() {
      $scope.tickets.push({name:"", price:"", quantity:0});
    };

    $scope.deleteTicket = function(index) {
      $scope.tickets[index]["destroy"] = "1";
    };

    $scope.changeStartTime = function (dateChange) {
      if(dateChange)
        $scope.time.dates.endDate = $scope.time.dates.startDate;

      // transform the date and time selectors in date format
      var startDate = $scope.time.dates.startDate || new Date();
      var endDate = $scope.time.dates.endDate || new Date();
      startTime = new Date (startDate.toDateString() + ' ' + $scope.time.times.startTime);
      endTime = new Date (endDate.toDateString() + ' ' + $scope.time.times.endTime);

      if(startTime >= endTime){
        // add one hour to end time
        startTime.setHours(startTime.getHours() + 1);
        $scope.time.dates.endDate = startTime;
        $scope.time.times.endTime = $filter('date')(startTime, 'h:mm a');
      }
    };

    // set calculated ticket price depending on producer fees and ticket price before fee
    $scope.calculateTicketPrice = function(ticket) {
      if($scope.includeFeeInPrice) {
        var fixedFee = $scope.producer ? $scope.producer.fixed_fee : 0;
        var percentFee = $scope.producer ? $scope.producer.percent_fee : 0;

        ticket.price = Math.round(fixedFee + ticket.priceBeforeFee * (1 + percentFee / 100));
      }
    };

    // re-calculate all ticket prices
    $scope.calculateAllTicketPrices = function() {
      _.each($scope.tickets, function(ticket) {
        $scope.calculateTicketPrice(ticket);
      });
    };

    // PRODUCERS MESSAGE
    $scope.submit = function(event) {
      //trigger form-validate directive
      // this is used to implement general validations (are not directly related to a input).
      $scope.$broadcast('formValidations');

      if(!$scope.form.$valid) {
        event.preventDefault();
      }

      if($scope.submitAction !== 'save' && $scope.producer && !$scope.producer.confirmed) {
        event.preventDefault();
        $scope.producerModal = true;
      }

      // reset submit action to undefined
      $scope.submitAction = undefined;
    };

    $scope.closeProducerModal = function() {
      $scope.producerModal = false;
    };

    // watch include fee property
    $scope.$watch('includeFeeInPrice', function() {
      // toggle to include fee in ticket price
      if($scope.includeFeeInPrice) {
        _.each($scope.tickets, function(ticket) {
          ticket.priceBeforeFee = ticket.price;
          $scope.calculateTicketPrice(ticket);
        });
      }
      // toggle to normal mode
      else {
        _.each($scope.tickets, function(ticket) {
          ticket.price = ticket.priceBeforeFee || ticket.price;
        });
      }
    });
  }
]);


// EVENTS/SHOW
angular.module('puntoTicketApp.controllers')
  .controller('EventShowCtrl', ['$scope', '$parse', function ($scope, $parse) {

    $scope.ticketTypes = [];
    // initialization tasks to be executed before the template enters execution mode
    // used to ruby data parsed into a JavaScript object

    $scope.init = function(ticketTypes, isPreview, ticketsLimit) {
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

// EVENTS TOPBAR
angular.module('puntoTicketApp.controllers')
  .controller('EventTopBarCtrl', ['$scope', '$parse', function ($scope) {

    $scope.themes = [];

    $scope.init = function(themes, currentTheme) {
      $scope.themes = themes;
      $scope.theme = currentTheme;
    };

    // change theme
    $scope.changeStyle = function(theme) {
      document.getElementById('theme_css').href = theme.url;
      $scope.theme = theme.name;
    };
  }
]);



