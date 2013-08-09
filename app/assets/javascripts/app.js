// Declare app level module which depends on filters, and services
angular.module('puntoTicketApp.resources', []);
angular.module('puntoTicketApp.services', []);
angular.module('puntoTicketApp.directives', ['$strap.directives', 'ui.bootstrap']);
angular.module('puntoTicketApp.filters', []);
angular.module('puntoTicketApp.controllers', []);
var App = angular.module('puntoTicketApp', ['puntoTicketApp.resources', 'puntoTicketApp.services', 'puntoTicketApp.directives', 'puntoTicketApp.filters', 'puntoTicketApp.controllers']);
