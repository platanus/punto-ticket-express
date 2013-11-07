angular.module('puntoTicketApp.controllers')
  .controller('TransactionNewCtrl', ['$scope', function ($scope) {

    $scope.init = function(_summaryData, _validPromoCode, _paymentMethod) {
      $scope.data = {};
      $scope.code = {entered: _validPromoCode, valid: null};
      $scope.data.ticketTypes = _summaryData;
      $scope.calculateAmounts();
      $scope.paymentMethod = _paymentMethod;
    };

    $scope.usePromoCode = function($event) {
      $scope.code.valid = null;
      $event.preventDefault();
      $scope.calculateAmounts();
    };

    var codeMatch = function(_hashCode) {
      if($scope.code.entered == null || $scope.code.entered == '')
        return false;

      var valid = (MD5($scope.code.entered) == _hashCode);

      if(valid) {
        $scope.code.valid = $scope.code.entered;
      }

      return valid;
    };

    $scope.calculateAmounts = function() {
      $scope.data.total = 0;
      $scope.data.total_discount = 0;

      angular.forEach($scope.data.ticketTypes, function(_type){
        $scope.data.total += parseInt(_type.price);

        console.log(_type.promotions)
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
