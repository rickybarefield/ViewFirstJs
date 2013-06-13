define ["ViewFirst", "Room", "Postman"], (ViewFirst) ->

   ViewFirst.Model.extend class House
  
     url: "house"
  
     constructor: (attributes) ->
       super()
       @createProperty("doorNumber")
       @createProperty("rooms", ViewFirst.OneToMany)
       @createProperty("postman", ViewFirst.ManyToOne)
      