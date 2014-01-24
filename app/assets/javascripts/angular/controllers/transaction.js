angular.module('puntoTicketApp.controllers')
  .controller('TransactionNewCtrl', ['$scope', '$modal', function ($scope, $modal) {

    var codeMatch = function(_hashCodes) {
      if(!$scope.code.entered) return false;
      var valid = false;

      angular.forEach(_hashCodes, function(_hashCode){
        if(_hashCode == MD5($scope.code.entered)) valid = true;
      });

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

        angular.forEach(_type.promotions, function(_promo){
          _promo.best_promo = false;
          _promo.visible = (_promo.codes.length == 0 || codeMatch(_promo.codes));
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
      console.log(_summaryData);
      $scope.data = {};
      $scope.code = {entered: _validPromoCode, valid: null};
      $scope.data.ticketTypes = _summaryData;
      calculateAmounts();
      changeView(_isParticipantsDataRequired, _errors);
    };

    //TODO: This is the wrong way to achieve this with angular.
    //NO jQuery into controller. NO manage DOM into controller
    //Improve this when change the form applying the angular
    //way instead the mix rails/angular way.
    var validateRequiredInputs = function(_form) {
      var valid = true;

      jQuery.each(jQuery(_form).find('input, select, textarea'), function(_idx, _comp) {
        var regex = /nested_resource/;
        if(regex.test(jQuery(_comp).attr('id'))) {
          var requiredAttr = jQuery(_comp).attr('required');
          var required = (typeof requiredAttr !== 'undefined' && requiredAttr !== false);
          if(jQuery(_comp).val() == '' && required) valid = false;
        }
      });

      return valid;
    };

    $scope.onTransactionSubmit = function($event) {
      if(!validateRequiredInputs($event.currentTarget)) {
        $event.preventDefault();
        $modal.open({templateUrl: 'requiredInputsModal.html'});
      }
    };

    $scope.goToSummary = function($event) {
      $event.preventDefault();
      var transactionForm = $($event.currentTarget).closest('form');

      if(!validateRequiredInputs(transactionForm)) {
        $modal.open({templateUrl: 'requiredInputsModal.html'});
        return;
      }

      $scope.showSummary = true;
    };

    $scope.usePromoCode = function($event) {
      $scope.code.valid = null;
      $event.preventDefault();
      calculateAmounts();

      if(!$scope.code.valid) {
        $modal.open({templateUrl: 'invalidCodeModal.html'});
      }
    };
  }
]);
