angular.module('puntoTicketApp.directives').directive('rutMask', function() {
  return {
    require: 'ngModel',

    link: function (_scope, _element, _attrs, _ngModel) {
      var cleanRut = function(_value) {
        if(!_value) return '';
        return _value.toString().replace(/[^0-9kK]+/g,'').toUpperCase();
      };

      var isRutValid = function(_value) {
        if(!_value) return true;
        _value = cleanRut(_value);

        var t = parseInt(_value.slice(0,-1), 10), m = 0, s = 1;
        while(t > 0) {
          s = (s + t%10 * (9 - m++%6)) % 11;
          t = Math.floor(t / 10);
        }
        var v = (s > 0) ? (s-1)+'' : 'K';

        return (v == _value.slice(-1));
      };

      // Write data to the model
      var setModelValue = function() {
        if(!_ngModel.$viewValue) return;
        var newValue = _ngModel.$viewValue;

        if(isRutValid(_ngModel.$viewValue)) {
          newValue = cleanRut(_ngModel.$viewValue).toUpperCase();
          var pos = newValue.length - 1;
          newValue = [newValue.slice(0, pos), "-", newValue.slice(pos)].join('');
        }

        _element.val(newValue);
      };

      // Listen for change events to enable binding
      _element.bind('blur', function() {
        _scope.$apply(setModelValue);
      });

      setModelValue();
    }
  };
});
