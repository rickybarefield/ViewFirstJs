// Generated by CoffeeScript 1.3.3
(function() {
  var Events, ViewFirstModelContainer,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Events = require("./ViewFirstEvents");

  module.exports = ViewFirstModelContainer = (function(_super) {

    __extends(ViewFirstModelContainer, _super);

    function ViewFirstModelContainer() {
      ViewFirstModelContainer.__super__.constructor.apply(this, arguments);
    }

    ViewFirstModelContainer.prototype.set = function(model) {
      var oldModel;
      oldModel = this.model;
      this.model = model;
      return this.trigger("change", oldModel, this.model);
    };

    return ViewFirstModelContainer;

  })(Events);

}).call(this);
