//PROMOTION/FORM
angular.module('puntoTicketApp.controllers')
  .controller('PromotionNewCtrl', ['$scope', 'DateUtils', function ($scope, DateUtils) {

    // ----------------------
    // PRIVATE METHODS
    // ----------------------
    var loadPromationObject = function(_promotion, _codeType) {
      if(!_codeType) _codeType = 'none';
      // set attrs on edit
      $scope.promotion = {
        id: _promotion.id,
        name: _promotion.name,
        startDate: _promotion.start_date,
        endDate: _promotion.end_date,
        limit: _promotion.limit,
        activation_code: _promotion.activation_code,
        promotable: _.findWhere($scope.promotables, {id: _promotion.promotable_id}),
        promotionType: _.findWhere($scope.promotionTypes, {id: _promotion.promotion_type}),
        promotionTypeConfig: _promotion.promotion_type_config,
        codeType: _codeType
      };

      loadPromotionDates();
    };

    var loadPromotionDates = function() {
      $scope.dates = {};
      // publish date & time
      if(!$scope.promotion.startDate || !$scope.promotion.endDate) {
        $scope.dates.startDate = DateUtils.tomorrow();
        $scope.dates.startTime = 0;
        $scope.dates.endDate = DateUtils.tomorrow();
        $scope.dates.endTime = 3600;

      } else {
        $scope.dates.startDate = DateUtils.toDate($scope.promotion.startDate);
        $scope.dates.startTime = DateUtils.timePartToSecs($scope.promotion.startDate);
        $scope.dates.endDate = DateUtils.toDate($scope.promotion.endDate);
        $scope.dates.endTime = DateUtils.timePartToSecs($scope.promotion.endDate);
      }
    };

    // ----------------------
    // INIT
    // ----------------------
    $scope.init = function(_promotion, _promotable, _promoTypes, _codeType) {
      $scope.promotables = _promotable;
      $scope.promotionTypes = _promoTypes;
      loadPromationObject(_promotion, _codeType);
      $scope.buildStartDatetime();
      $scope.buildEndDatetime();
    };

    // ----------------------
    // ACTIONS METHODS
    // ----------------------
    // called when the time or date change
    $scope.buildStartDatetime = function() {
      if(!$scope.dates.startDate || !$scope.dates.startTime)
        $scope.dates.startDateTime = null;
      $scope.dates.startDateTime = DateUtils.toRailsDate(
        DateUtils.addSeconds($scope.dates.startDate, $scope.dates.startTime));
    };
    // called when the time or date change
    $scope.buildEndDatetime = function() {
      if(!$scope.dates.endDateTime || !$scope.dates.endTime)
        $scope.dates.endDateTime = null;
      $scope.dates.endDateTime = DateUtils.toRailsDate(
        DateUtils.addSeconds($scope.dates.endDate, $scope.dates.endTime));
    };
  }
]);
