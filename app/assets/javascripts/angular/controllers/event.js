// EVENTS/NEW
angular.module('puntoTicketApp.controllers')
  .controller('EventNewCtrl', ['$scope', '$filter', 'defineTime', '$window', function ($scope, $filter, defineTime, $window) {

    $scope.tickets = [];
    // Defines the reason for submiting the form
    // 'save' is for saving the event
    $scope.submitAction = undefined;

    $scope.init = function(event, producers) {
      $scope.producers = producers;
      $scope.disabled = (producers.length == 0);
      $scope.name = event.name;
      $scope.address = event.address;
      $scope.producerId = event.producer_id || producers[0].id;
      // value of commissions
      $scope.fixedFee = producers[0].fixed_fee;
      $scope.percentFee = producers[0].percent_fee;
      // call factory
      $scope.time = defineTime.time(event.start_time, event.end_time);
      $scope.tickets = event.ticket_types;

      // it warns not to leave the form without saving data
      if(!event.is_published && !event.id)
        $scope.$watch('submitAction', function(newValue, oldValue) {
          if(newValue !== 'save' && oldValue !== 'save') {
            $window.onbeforeunload = function(){
              return 'Esta apunto de abandonar esta pagina sin haber guardado sus datos.';
            };
          }else{
            $window.onbeforeunload = undefined;
          }
        });
    };

    $scope.addTicket = function() {
      $scope.tickets.push({name:"", price:"", quantity:0});
    };

    $scope.deleteTicket = function(index) {
      $scope.tickets[index]["destroy"] = "1";
    };

    $scope.changeStartTime = function (dateChange) {
      if(dateChange)
        $scope.time.dates.endDate = $scope.time.dates.startDate;

      // transform the date and time selectors in date format
      var startDate = $scope.time.dates.startDate || new Date();
      var endDate = $scope.time.dates.endDate || new Date();
      startTime = new Date (startDate.toDateString() + ' ' + $scope.time.times.startTime);
      endTime = new Date (endDate.toDateString() + ' ' + $scope.time.times.endTime);

      if(startTime >= endTime){
        // add one hour to end time
        startTime.setHours(startTime.getHours() + 1);
        $scope.time.dates.endDate = startTime;
        $scope.time.times.endTime = $filter('date')(startTime, 'h:mm a');
      }
    };

    // change select
    $scope.changeProducer = function(producerId) {
        var producer = _.find($scope.producers, function(producer){
          return producer.id == $scope.producerId;
        });
        // update commission values
        $scope.fixedFee = producer ? producer.fixed_fee : 0;
        $scope.percentFee = producer ? producer.percent_fee : 0;
    };

    // apply commissions
    $scope.sumTotalWithFee = function(ticketType, totalBeforeFee) {
      ticketType.price = Math.round($scope.fixedFee + totalBeforeFee * (1 + $scope.percentFee / 100));
    };

    // PRODUCERS MESSAGE
    $scope.submit = function(event) {
      if($scope.submitAction !== 'save') {
        for(var i = 0; i < $scope.producers.length; i++ ){
          if((($scope.producers[i].id.toString() == $scope.producerId) &&
            !$scope.producers[i].confirmed) || $scope.producerId == undefined) {
            event.preventDefault();
            $scope.producerModal = true;
            break;
          }
        }
      }

      // reset submit action to undefined
      $scope.submitAction = undefined;
    };

    $scope.closeProducerModal = function() {
      $scope.producerModal = false;
    };
  }
]);


// EVENTS/SHOW
angular.module('puntoTicketApp.controllers')
  .controller('EventShowCtrl', ['$scope', '$parse', function ($scope, $parse) {

    $scope.ticketTypes = [];
    // initialization tasks to be executed before the template enters execution mode
    // used to ruby data parsed into a JavaScript object

    $scope.init = function(ticketTypes, url, isPreview) {
      // eliminates unnecessary attributes
      _.each(ticketTypes, function(ticketType){
        // set default select option
        ticketType.qty = 0;
        // rremove attrs
        delete ticketType.created_at;
        delete ticketType.updated_at;
      });

      $scope.isPreview = isPreview;
      $scope.ticketTypes = ticketTypes;
      $scope.actionUrl = url;
    };

    $scope.closeBuyModal = function() {
      $scope.buyModal = false;
    };

    $scope.closeNoTicketsModal = function() {
      $scope.notTicketsModal = false;
    };

    // removes and validates the fields of the array before being sent to the next page
    $scope.sendTicket = function($event) {

      // removes all ticket_types that have no amount
      var ticketTypes = _.filter($scope.ticketTypes, function(t){
        return (t.qty && t.qty > 0);
      });

      // if all tickets are equal to zero is sent a warning
      if(_.size(ticketTypes) == 0) {
        // default action of the event will not be triggered
        $event.preventDefault();
        $scope.notTicketsModal = true;

      } else if($scope.isPreview) {
        $event.preventDefault();
        $scope.buyModal = true;

      } else {
        $scope.ticketTypesAfterFilter = ticketTypes;
      }
    };
  }
]);

// EVENTS TOPBAR
angular.module('puntoTicketApp.controllers')
  .controller('EventTopBarCtrl', ['$scope', '$parse', function ($scope) {

    $scope.themes = [];

    $scope.init = function(themes, currentTheme) {
      $scope.themes = themes;
      $scope.theme = currentTheme;
    };

    // change theme
    $scope.changeStyle = function(theme) {
      document.getElementById('theme_css').href = theme.url;
      $scope.theme = theme.name;
    };
  }
]);



