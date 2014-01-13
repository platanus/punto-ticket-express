angular.module('puntoTicketApp.directives').directive('dirtyAfterSubmit', function() {
  return {
    restrict: 'A',
    link: function(scope, formElement, attrs) {
      form = scope[attrs.name]['nested_form'];
  
      formElement.bind('submit', function() { 
        angular.forEach(form, function(field, name) {
          if(typeof(name) == 'string' && !name.match('^[\$]') && field.$pristine) {
            field.$setViewValue(
              field.$modelValue
            );
          }
        });
      });
    }
  };
});
