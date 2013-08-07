angular.module('puntoTicketApp.directives').directive('formValidate', function() {
  return {
    restrict: 'EA',
    require: '?ngModel',
    scope: true,
    link: function(scope, elm, attrs, ctrl) {

      ctrl.$parsers.unshift(function(viewValue) {
        resolveValidation(viewValue);
        validateForm();
      });

      function resolveValidation(viewValue) {
        switch (attrs.validateType) {
        case "requireds":
          scope.isValid = (viewValue && viewValue !== " " ? 'valid' : undefined);
          break;
        case "minRepeat":
          scope.isValid = (_.size(viewValue) > 0 ? 'valid' : undefined);
          break;
        }
      }

      scope.$on('kickOffValidations', validateForm);
      function validateForm() {

        resolveValidation(ctrl.$viewValue);
        console.log(ctrl.$viewValue);

        if(scope.isValid) {
          ctrl.$setValidity(attrs.validateType, true);
        } else {
          ctrl.$setValidity(attrs.validateType, false);
        }
      }
    }
  };
});
