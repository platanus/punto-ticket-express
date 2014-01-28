angular.module('puntoTicketApp.controllers')
  .controller('PromotionNewCtrl', ['$scope', function ($scope) {

    var loadPromationObject = function(_promotion) {
      rails_date_format = "MM-DD-YYYY";

      $scope.promotion = {
        id: _promotion.id,
        name: _promotion.name,
        startDate: moment(_promotion.start_date, rails_date_format),
        endDate: moment(_promotion.end_date, rails_date_format),
        limit: _promotion.limit,
        activation_code: _promotion.activation_code,
        promotable: _.findWhere($scope.promotables, {id: _promotion.promotable_id}),
        promotionType: _.findWhere($scope.promotionTypes, {id: _promotion.promotion_type}),
        promotionTypeConfig: _promotion.promotion_type_config
      };
    };

    $scope.init = function(_promotion, _promotable, _promoTypes) {
      $scope.promotables = _promotable;
      $scope.promotionTypes = _promoTypes;
      loadPromationObject(_promotion);
    };
  }
]);
