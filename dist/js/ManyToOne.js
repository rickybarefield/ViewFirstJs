// Generated by CoffeeScript 1.4.0
(function() {

  define(function() {
    var ManyToOne;
    return ManyToOne = (function() {

      function ManyToOne() {}

      ManyToOne.prototype.addToJson = function(json) {
        if (this.value != null) {
          return json[this.name] = {
            id: this.value.get("id")
          };
        } else {
          return json[this.name] = null;
        }
      };

      ManyToOne.prototype.setFromJson = function(json, clean) {
        this.isDirty = !clean;
        if (json != null) {
          return this.value = this.type.load(json);
        } else {
          return this.value = null;
        }
      };

      ManyToOne.prototype.getProperty = function(name) {
        return this.value.getProperty(name);
      };

      return ManyToOne;

    })();
  });

}).call(this);
