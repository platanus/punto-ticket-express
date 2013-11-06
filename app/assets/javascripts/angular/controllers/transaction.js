angular.module('puntoTicketApp.controllers')
  .controller('TransactionNewCtrl', ['$scope', function ($scope) {

    $scope.init = function(_summaryData) {
      console.log(_summaryData)
      $scope.data = {};
      $scope.data.code = null;
      $scope.data.ticketTypes = _summaryData;
      $scope.calculateAmounts();
    };

    $scope.usePromoCode = function($event) {
      $event.preventDefault();
      $scope.calculateAmounts();
    };

    var codeMatch = function(_hashCode) {
      if($scope.data.code == null || $scope.data.code == '') {
        return false;
      }
      return (MD5($scope.data.code) == _hashCode);
    };

    $scope.calculateAmounts = function() {
      $scope.data.total = 0;
      $scope.data.total_discount = 0;

      angular.forEach($scope.data.ticketTypes, function(_type){
        $scope.data.total += _type.price;

        angular.forEach(_type.promotions, function(_promo){
          _promo.best_promo = false;
          _promo.visible = (_promo.code == null || _promo.code == '' || codeMatch(_promo.code));
        });

        for(var i = _type.promotions.length - 1; i >= 0; i--) {
          if(_type.promotions[i].visible) {
            $scope.data.total_discount += parseInt(_type.promotions[i].discount);
            _type.promo_price = _type.price - _type.promotions[i].discount;
            _type.promotions[i].best_promo = true;
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
