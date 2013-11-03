angular.module('puntoTicketApp.controllers')
  .controller('TransactionNewCtrl', ['$scope', function ($scope) {

    $scope.init = function(_summaryData) {
      $scope.data = {};
      $scope.data.code = null;
      $scope.data.ticketTypes = _summaryData;
      $scope.calculateAmounts();
    };

    $scope.usePromoCode = function($event) {
      $event.preventDefault();
      $scope.calculateAmounts();
    };

    $scope.calculateAmounts = function() {
      $scope.data.total = 0;
      $scope.data.total_discount = 0;

      angular.forEach($scope.data.ticketTypes, function(_type){
        $scope.data.total += _type.price;

        angular.forEach(_type.promotions, function(_promo){
          _promo.available = false;
          _promo.visible = (_promo.code == null || _promo.code == '' || _promo.code == $scope.data.code);
        });

        console.log(_type.promotions);
        for(var i = _type.promotions.length - 1; i >= 0; i--) {
          if(_type.promotions[i].visible) {
            $scope.data.total_discount += _type.promotions[i].discount;
            _type.promo_price = _type.price - _type.promotions[i].discount;
            _type.promotions[i].available = true;
            break;
          }
        }
      });

      $scope.data.total_to_pay = $scope.data.total - $scope.data.total_discount;
    };

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
