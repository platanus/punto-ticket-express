angular.module('puntoTicketApp.controllers')
  .controller('PromotionNewCtrl', ['$scope', function ($scope) {
    $scope.init = function(_promotion) {
      rails_date_format = "MM-DD-YYYY";
      $scope.promotion = {};
      $scope.promotion.startDate = moment(_promotion.start_date, rails_date_format);
      $scope.promotion.endDate = moment(_promotion.end_date, rails_date_format);
    };
  }
]);
