angular.module('puntoTicketApp.controllers')
  .controller('EventCtrl', ['$scope', '$filter', function ($scope, $filter) {
    $scope.tickets = [];

    var nowDate = new Date();
    var nowTime = $filter('date')(nowDate, 'h:mm a');
    $scope.datepicker = {startDate: nowDate, endDate: nowDate};
    $scope.timepicker = {startTime: nowTime, endTime: nowTime};

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
