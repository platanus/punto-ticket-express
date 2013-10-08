// EVENTS/NEW
angular.module('puntoTicketApp.controllers')
  .controller('EventNewCtrl', ['$scope', '$filter', 'defineTime', function ($scope, $filter, defineTime) {

    $scope.tickets = [];
    // Defines the reason for submiting the form
    // 'save' is for saving the event
    $scope.submitAction = undefined;

    $scope.init = function(event, producers) {
      $scope.producers = producers;
      $scope.disabled = (producers.length == 0);
      $scope.name = event.name;
      $scope.address = event.address;
      $scope.producerId = event.producer_id
      //call factory
      $scope.time = defineTime.time(event.start_time, event.end_time);
      $scope.tickets = event.ticket_types;
    };

    $scope.addTicket = function() {
      $scope.tickets.push({name:"", price:"", quantity:0});
    };

    $scope.deleteTicket = function(index) {
      $scope.tickets[index]["destroy"] = "1"
    };

    // triggers the method set out in the validations directive
    $scope.allowValidation = function () {
      $scope.$broadcast('kickOffValidations');
    };

    $scope.changeStartDate = function () {
      $scope.time.dates.endDate = $scope.time.dates.startDate
    }

    // PRODUCERS MESSAGE
    $scope.submit = function(event) {
      if($scope.submitAction !== 'save') {
        for(var i = 0; i < $scope.producers.length; i++ ){
          if((($scope.producers[i].id.toString() == $scope.producerId) &&
            !$scope.producers[i].confirmed) || $scope.producerId == undefined) {
            event.preventDefault();
            $scope.producerModal = true;
            break;
          }
        }
      }

      // reset submit action to undefined
      $scope.submitAction = undefined;
    };

    $scope.closeProducerModal = function() {
      $scope.producerModal = false;
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

    $scope.init = function(ticketTypes, url, isPreview) {
      // eliminates unnecessary attributes
      _.each(ticketTypes, function(ticketType){
        // set default select option
        ticketType.qty = 0;
        // rremove attrs
        delete ticketType.created_at
        delete ticketType.updated_at
      });

      $scope.isPreview = isPreview
      $scope.ticketTypes = ticketTypes;
      $scope.actionUrl = url;
    };

    $scope.closeBuyModal = function() {
      $scope.buyModal = false;
    }

    $scope.closeNoTicketsModal = function() {
      $scope.notTicketsModal = false;
    }

    // removes and validates the fields of the array before being sent to the next page
    $scope.sendTicket = function($event) {

      // removes all ticket_types that have no amount
      var ticketTypes = _.filter($scope.ticketTypes, function(t){ return t.qty && t.qty > 0 });

      // if all tickets are equal to zero is sent a warning
      if(_.size(ticketTypes) == 0) {
        // default action of the event will not be triggered
        $event.preventDefault();
        $scope.notTicketsModal = true;

      } else if($scope.isPreview) {
        $event.preventDefault();
        $scope.buyModal = true;

      } else {
        $scope.ticketTypesAfterFilter = ticketTypes;
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
    }

    // change theme
    $scope.changeStyle = function(theme) {
      document.getElementById('theme_css').href = theme.url;
      $scope.theme = theme.name;
    }
  }
]);



