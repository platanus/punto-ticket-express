// EVENTS/NEW
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