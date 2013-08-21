angular.module('puntoTicketApp.controllers')
.controller('EventCtrl', ['$scope', '$filter', function ($scope, $filter) {
  $scope.tickets = [];

  var nowDate = new Date();
  var nowTime = $filter('date')(nowDate, 'h:mm a');
    //$scope.datepicker = {startDate: nowDate, endDate: nowDate};
    //$scope.timepicker = {startTime: nowTime, endTime: nowTime};
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
  .controller('TabsEventCtrl', ['$scope', function ($scope) {

    $scope.tabs = [
      { title:"Grafico de barras", content:"Dynamic content 1" },
      { title:"Grafico de torta", content:"Dynamic content 2" }
    ];

    $scope.navType = 'pills';
  }
]);
