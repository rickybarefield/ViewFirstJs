// Generated by CoffeeScript 1.4.0
(function() {

  define(["Scrud-0.1"], function(Scrud) {
    var Sync;
    Sync = (function() {

      function Sync(url) {
        this.url = url;
      }

      Sync.prototype.connect = function() {};

      Sync.prototype.connectCollection = function() {
        return console.log(arguments);
      };

      return Sync;

    })();
    return Sync;
  });

}).call(this);
