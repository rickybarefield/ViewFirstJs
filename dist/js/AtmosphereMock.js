// Generated by CoffeeScript 1.4.0
(function() {

  define(["jquery"], function($) {
    var AtmosphereMock;
    AtmosphereMock = {
      initialize: function() {
        return $.atmosphere = {
          subscribe: function(request) {
            return AtmosphereMock.lastSubscribe = request;
          }
        };
      }
    };
    return AtmosphereMock;
  });

}).call(this);
