define ["ViewFirst", "Room", "Postman"], (ViewFirst, Room, Postman) ->

   House = ViewFirst.Model.extend class House
  
     @type: "house"
  
     constructor: (attributes) ->
       @createProperty("doorNumber", Number)
       @createProperty("rooms", Room, ViewFirst.OneToMany)
       @createProperty("postman", Postman, ViewFirst.ManyToOne)
      