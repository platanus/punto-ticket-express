angular.module('puntoTicketApp.controllers')
.controller('EventNewCtrl', ['$scope', '$filter', function ($scope, $filter) {
  $scope.tickets = [];

  var nowDate = new Date();
  var nowTime = $filter('date')(nowDate, 'h:mm a');

    $scope.time = {
      dates: {startDate: nowDate, endDate: nowDate},
      times: {startTime: nowTime, endTime: nowTime}
    };

    $scope.addTicket = function() {
      $scope.tickets.push({name:"", price:"", qty:0});
    };

    $scope.deleteTicket = function(index) {
      $scope.tickets.splice(index, 1);
    };

    $scope.allowValidation = function () {
      $scope.$broadcast('kickOffValidations');
    };
  }
]);


angular.module('puntoTicketApp.controllers')
  .controller('EventDashboardCtrl', ['$scope', function ($scope) {

    $scope.tabs = [
      { title:"Grafico de barras", content:"Dynamic content 1" },
      { title:"Grafico de torta", content:"Dynamic content 2" }
    ];

    $scope.navType = 'pills';
  }
]);


angular.module('puntoTicketApp.controllers')
  .controller('EventShowCtrl', ['$scope', function ($scope) {

    $scope.ticketTypes = [];
    // initialization tasks to be executed before the template enters execution mode
    // used to ruby data parsed into a JavaScript object

    $scope.init = function(ticketTypes) {
      $scope.ticketTypes = ticketTypes;

      // assigned a default value for the select
      $scope.ticketType = $scope.ticketTypes[0];
    };
  }
]);