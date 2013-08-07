// Generated by CoffeeScript 1.4.0
(function() {

  define(["ViewFirst", "Room", "Postman"], function(ViewFirst, Room, Postman) {
    var House;
    return House = ViewFirst.Model.extend(House = (function() {

      House.url = "/houses";

      function House(attributes) {
        this.createProperty("doorNumber", Number);
        this.createProperty("rooms", Room, ViewFirst.OneToMany);
        this.createProperty("postman", Postman, ViewFirst.ManyToOne);
      }

      return House;

    })());
  });

}).call(this);
