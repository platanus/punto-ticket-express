angular.module('puntoTicketApp.directives').directive('removeNestedAttribute', function() {
  return {
    link: function (scope, element, attrs) {
      element.on("click", function() {
        element.parents("tr").hide();
      });
    }
  };
});
