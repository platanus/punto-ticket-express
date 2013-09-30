angular.module('puntoTicketApp.directives').directive('formValidate', function() {
  return {
    restrict: 'EA',
    require: '?ngModel',
    link: function(scope, elm, attrs, ctrl) {

      // ctrl.$parsers.unshift(function(viewValue) {
      //   // rememeber add condition if attrs.modelRef
      //   alert(JSON.stringify(scope[attrs.modelRef]));
      //   alert(JSON.stringify(viewValue));
      //   resolveValidation(viewValue);
      //   validateForm();
      //   return viewValue;
      // });

      scope.$watch(attrs.ngModel, function(before, after) {
        if(before !== after){
          resolveValidation(after);
          validateForm();
        }
      }, true);

      function resolveValidation(viewValue) {
        outside:
        switch (attrs.validateType) {
          case "minrepeat":
            scope.isValid = _.size(viewValue) > 0 ? 'valid' : undefined;
            break;
          case "starttime":

            if(!viewValue.dates.startDate) {
              scope.isValid = 'valid';
              break outside;
            }

            var startTime = new Date (viewValue.dates.startDate.toDateString() + ' ' + viewValue.times.startTime);
            var currentTime = new Date();
            scope.isValid = startTime > currentTime ? 'valid' : undefined;
            break;
          case "startgreaterend":

            if(!viewValue.dates.startDate || !viewValue.dates.endDate) {
              scope.isValid = 'valid';
              break outside;
            }
            var startTime = new Date (viewValue.dates.startDate.toDateString() + ' ' + viewValue.times.startTime);
            var endTime = new Date (viewValue.dates.endDate.toDateString() + ' ' + viewValue.times.endTime);
            scope.isValid = startTime - endTime < 0 ? 'valid' : undefined;
          }
      }

      scope.$on('kickOffValidations', validateForm);
      function validateForm() {

        resolveValidation(ctrl.$viewValue);
        ctrl.$dirty = true;
        scope.$dirty = true;

        if(!attrs.validateType)
          return;

        if(scope.isValid) {
          ctrl.$setValidity(attrs.validateType, true);
        } else {
          ctrl.$setValidity(attrs.validateType, false);
        }
      }
    }
  };
});
