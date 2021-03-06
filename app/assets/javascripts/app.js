angular.module('puntoTicketApp.resources', []);
angular.module('puntoTicketApp.services', []);
angular.module('puntoTicketApp.validators', []);
angular.module('puntoTicketApp.directives', [
    '$strap.directives',
    'ui.bootstrap',
    'platanus.rut',
    'platanus.misc']);
angular.module('puntoTicketApp.filters', []);
angular.module('puntoTicketApp.controllers', []);
var App = angular.module('puntoTicketApp', [
    'platanus.validate',
    'puntoTicketApp.resources',
    'puntoTicketApp.services',
    'puntoTicketApp.validators',
    'puntoTicketApp.directives',
    'puntoTicketApp.filters',
    'puntoTicketApp.controllers'])
.config(['$i10nProvider', function($i10nProvider) {
    $i10nProvider.setLocalePrefs(['es.common']);
}]);
