define ["ViewFirst", "Room", "Postman"], (ViewFirst, Room, Postman) ->

   House = ViewFirst.Model.extend class House
  
     url: "houses"
  
     constructor: (attributes) ->
       @createProperty("doorNumber", Number)
       @createProperty("rooms", Room, ViewFirst.OneToMany)
       @createProperty("postman", Postman, ViewFirst.ManyToOne)
      