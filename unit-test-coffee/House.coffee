ViewFirst = require("./ViewFirst")
Room = require("./Room")
Postman = require("./Postman")

module.exports = ViewFirst.Model.extend class House
  
     @type: "house"
  
     constructor: (attributes) ->
       @createProperty("doorNumber", Number)
       @createProperty("rooms", Room, ViewFirst.OneToMany)
       @createProperty("postman", Postman, ViewFirst.ManyToOne)
      