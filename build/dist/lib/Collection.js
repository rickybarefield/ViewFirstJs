// Generated by CoffeeScript 1.3.3
(function() {
  var Collection, Events,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Events = require("./ViewFirstEvents");

  module.exports = Collection = (function(_super) {

    __extends(Collection, _super);

    function Collection() {
      Collection.__super__.constructor.apply(this, arguments);
      this.instances = {};
    }

    Collection.prototype.getAll = function() {
      var key, value, _ref, _results;
      _ref = this.instances;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(value);
      }
      return _results;
    };

    Collection.prototype.size = function() {
      return Object.keys(this.instances).length;
    };

    Collection.prototype.add = function(model, silent) {
      if (silent == null) {
        silent = false;
      }
      if ((this.instances[model.clientId] != null)) {
        return false;
      }
      this.instances[model.clientId] = model;
      if (!silent) {
        this.trigger("add", model);
      }
      return true;
    };

    Collection.prototype.remove = function(model) {
      delete this.instances[model.clientId];
      return this.trigger("remove", model);
    };

    return Collection;

  })(Events);

}).call(this);
