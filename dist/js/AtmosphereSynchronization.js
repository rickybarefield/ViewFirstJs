// Generated by CoffeeScript 1.4.0
(function() {

  define(["jquery"], function($) {
    /*
    
        This class provides the glue between ViewFirst models and the server, it could be swapped out for another implementation.  It should not have knowledge of the rest of the ViewFirst framework.
    */

    var AtmosphereSynchronization;
    AtmosphereSynchronization = {
      connectCollection: function(url, callbackFunctions) {
        var request, subSocket;
        if ($.atmosphere == null) {
          throw "The JQuery atmosphere plugin must be loaded";
        }
        request = {
          url: url,
          contentType: "application/json",
          logLevel: 'debug',
          transport: 'websocket'
        };
        request.onMessage = function(response) {
          var message, model, _i, _len, _results;
          message = $.parseJSON(response.responseBody);
          if (Array.isArray(message)) {
            _results = [];
            for (_i = 0, _len = message.length; _i < _len; _i++) {
              model = message[_i];
              _results.push(callbackFunctions['create'](model));
            }
            return _results;
          } else if (message.event != null) {
            switch (message.event) {
              case "CREATE":
                return callbackFunctions['create'](message.entity);
              case "UPDATE":
                return callbackFunctions['update'](message.entity);
              case "DELETE":
                return callbackFunctions['delete'](message.entity);
              case "REMOVE":
                return callbackFunctions['remove'](message.entity);
              default:
                return console.error("Unknown event '" + message.event + "', silently ignoring");
            }
          } else {
            return callbackFunctions['create'](message);
          }
        };
        request.onError = function(response) {
          return console.error("error: " + response);
        };
        return subSocket = $.atmosphere.subscribe(request);
      },
      persist: function(url, json, callbackFunctions) {
        return $.ajax(url, {
          type: 'POST',
          data: json,
          contentType: "application/json",
          success: callbackFunctions['success']
        });
      },
      update: function(url, json, callbackFunctions) {
        return $.ajax(url, {
          type: 'PUT',
          data: json,
          contentType: "application/json",
          success: callbackFunctions['success']
        });
      }
    };
    return AtmosphereSynchronization;
  });

}).call(this);
