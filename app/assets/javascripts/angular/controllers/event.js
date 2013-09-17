// EVENTS/NEW
angular.module('puntoTicketApp.controllers')
  .controller('EventNewCtrl', ['$scope', '$filter', 'defineTime', function ($scope, $filter, defineTime) {

    $scope.tickets = [];

    $scope.init = function(event) {
      $scope.name = event.name;
      $scope.address = event.address;
      $scope.organizerName = event.organizer_name;
      //call factory
      $scope.time = defineTime.time(event.start_time, event.end_time);
      $scope.tickets = event.ticket_types;
    };

    $scope.addTicket = function() {
      $scope.tickets.push({name:"", price:"", quantity:0});
    };

    $scope.deleteTicket = function(index) {
      $scope.tickets.splice(index, 1);
    };

    // triggers the method set out in the validations directive
    $scope.allowValidation = function () {
      $scope.$broadcast('kickOffValidations');
    };
  }
]);

// EVENTS/DASHBOARD
angular.module('puntoTicketApp.controllers')
  .controller('EventDashboardCtrl', ['$scope', function ($scope) {

    // Angular UI tabs
    $scope.tabs = [
      { title:"Grafico de barras", content:"Dynamic content 1" },
      { title:"Grafico de torta", content:"Dynamic content 2" }
    ];

    $scope.navType = 'pills';
  }
]);

// EVENTS/SHOW
angular.module('puntoTicketApp.controllers')
  .controller('EventShowCtrl', ['$scope', '$parse', function ($scope, $parse) {

    $scope.ticketTypes = [];
    // initialization tasks to be executed before the template enters execution mode
    // used to ruby data parsed into a JavaScript object

    $scope.init = function(ticketTypes, url) {
      // eliminates unnecessary attributes
      _.each(ticketTypes, function(ticketType){
        // set default select option
        ticketType.qty = 0;
        // rremove attrs
        delete ticketType.created_at
        delete ticketType.updated_at
      });

      $scope.ticketTypes = ticketTypes;
      $scope.actionUrl = url;
    };

    // removes and validates the fields of the array before being sent to the next page
    $scope.sendTicket = function($event) {

      // removes all ticket_types that have no amount
      var ticketTypes = _.filter($scope.ticketTypes, function(t){ return t.qty && t.qty > 0 });

      // if all tickets are equal to zero is sent a warning
      if(_.size(ticketTypes) == 0) {
        // default action of the event will not be triggered
        $event.preventDefault()
        alert('No puede comprar 0 tickets!')
      }
      else
        $scope.ticketTypes = ticketTypes;
    };
  }
]);