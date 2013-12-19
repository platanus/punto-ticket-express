angular.module('puntoTicketApp.controllers')
  .controller('TransactionNewCtrl', ['$scope', function ($scope) {

    var codeMatch = function(_hashCode) {
      if($scope.code.entered == null || $scope.code.entered == '')
        return false;

      var valid = (MD5($scope.code.entered) == _hashCode);

      if(valid) {
        $scope.code.valid = $scope.code.entered;
      }

      return valid;
    };

    var calculateAmounts = function() {
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

    var changeView = function(_isParticipantsDataRequired, _errors) {
      $scope.hasParticipantsDataErrors = _errors.participants_data;
      $scope.hasTransactionErrors = _errors.transaction;

      if($scope.hasParticipantsDataErrors) {
        $scope.showSummary = false;
        return;
      }

      if($scope.hasTransactionErrors) {
        $scope.showSummary = true;
        return;
      }

      $scope.showSummary = !_isParticipantsDataRequired;
    };

    $scope.discountApplied = function() {
      if(!$scope.data || !$scope.data.total_discount) return false;
      return (parseInt($scope.data.total_discount) != 0);
    };

    $scope.init = function(_summaryData, _validPromoCode, _isParticipantsDataRequired, _errors) {
      $scope.data = {};
      $scope.code = {entered: _validPromoCode, valid: null};
      $scope.data.ticketTypes = _summaryData;
      calculateAmounts();
      changeView(_isParticipantsDataRequired, _errors);
    };

    $scope.goToSummary = function($event) {
      $event.preventDefault();
      $scope.showSummary = true;
    };

    $scope.closeInvalidCodeModal = function() {
      $scope.invalidCodeModal = false;
    };

    $scope.onBuyButtonClick = function() {
      if($scope.tickets_form.$invalid)
        $scope.notTicketsModal = true;
    };

    $scope.closeNoPaymentsModal = function() {
      $scope.notTicketsModal = false;
    };

    $scope.usePromoCode = function($event) {
      $scope.code.valid = null;
      $event.preventDefault();
      calculateAmounts();

      if(!$scope.code.valid) {
        $scope.invalidCodeModal = true;
      }
    };
  }
]);
