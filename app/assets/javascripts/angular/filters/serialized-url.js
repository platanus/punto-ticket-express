// serializes an javascript object so it can be sent through to a url and concatenated with a url
angular.module('puntoTicketApp.filters', []).filter('serailizedUrl', function() {
  return function(obj, url) {
  	url = url || "";

  	var serialize = function(obj, prefix) {
    	var str = [];
    	for(var p in obj) {
        	var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
        	str.push(typeof v == "object" ?
            	serialize(v, k) :
            	encodeURIComponent(k) + "=" + encodeURIComponent(v));
    	}
    	return str.join("&");
	};

    return url + '?' + serialize(obj);
  };
});