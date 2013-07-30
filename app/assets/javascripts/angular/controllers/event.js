angular.module('puntoTicketApp.controllers').controller('EventCtrl', function ($scope, $filter) {
  $scope.tickets = [];

  var nowDate = new Date();
  var nowTime = $filter('date')(nowDate, 'h:mm a');
  $scope.datepicker = {startDate: nowDate, endDate: nowDate};
  $scope.timepicker = {startTime: nowTime, endTime: nowTime};

  $scope.addTicket = function() {
    $scope.tickets.push({id:_.size($scope.tickets), name:"", price:"", qty:0});
  };

  $scope.deleteTicket = function(ticket) {
    var index = $scope.tickets.indexOf(ticket);
    $scope.tickets.splice(index,1);
  };
});
