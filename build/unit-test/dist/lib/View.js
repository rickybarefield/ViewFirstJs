// Generated by CoffeeScript 1.3.3
(function() {
  var $,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $ = require('./jquery-dep');

  module.exports = window.View = (function() {

    View.TEXT_NODE = 3;

    function View(viewId, element) {
      this.viewId = viewId;
      this.element = element;
      this.getElement = __bind(this.getElement, this);

    }

    View.prototype.getElement = function() {
      return this.element;
    };

    return View;

  })();

}).call(this);