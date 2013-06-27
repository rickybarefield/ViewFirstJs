define ["ViewFirst", "Room", "Postman"], (ViewFirst) ->

   House = ViewFirst.Model.extend class House
  
     url: "house"
  
     constructor: (attributes) ->
       @createProperty("doorNumber")
       @createProperty("rooms", ViewFirst.OneToMany)
       @createProperty("postman", ViewFirst.ManyToOne)
      