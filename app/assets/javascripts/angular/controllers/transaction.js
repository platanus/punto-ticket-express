angular.module('puntoTicketApp.controllers')
  .controller('TransactionNewCtrl', ['$scope', function ($scope) {

    $scope.startTransaction = function($event) {
      if(!$scope.paymentMethod) {
        $event.preventDefault();
        $scope.notPaymentModal = true;
      }
    };

    $scope.closeNoPaymentModal = function() {
      $scope.notPaymentModal = false;
    };
  }
]);
