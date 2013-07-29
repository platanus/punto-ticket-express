App.controller('EventCtrl', function ($scope) {
  $scope.tickets = [];

  $scope.addTicket = function() {
    $scope.tickets.push({id:_.size($scope.tickets), name:"", price:"", quantity:0});
  };

  $scope.deleteTicket = function(ticket) {
    var index = $scope.tickets.indexOf(ticket);
    $scope.tickets.splice(index,1);
  };
});
