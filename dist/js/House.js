// Generated by CoffeeScript 1.4.0
(function() {
  var House, Postman, Room, ViewFirst;

  ViewFirst = require("./ViewFirst");

  Room = require("./Room");

  Postman = require("./Postman");

  module.exports = ViewFirst.Model.extend(House = (function() {

    House.type = "house";

    function House(attributes) {
      this.createProperty("doorNumber", Number);
      this.createProperty("rooms", Room, ViewFirst.OneToMany);
      this.createProperty("postman", Postman, ViewFirst.ManyToOne);
    }

    return House;

  })());

}).call(this);
