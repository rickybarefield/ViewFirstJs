// Generated by CoffeeScript 1.3.3
(function() {
  var Room, ViewFirst;

  ViewFirst = require("./ViewFirst");

  module.exports = ViewFirst.Model.extend(Room = (function() {

    Room.type = "room";

    function Room() {
      this.createProperty("colour", String);
      this.createProperty("size", Number);
    }

    return Room;

  })());

}).call(this);
