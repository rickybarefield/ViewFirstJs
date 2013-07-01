define ["ViewFirst", "Room", "Postman"], (ViewFirst) ->

   House = ViewFirst.Model.extend class House
  
     url: "houses"
  
     constructor: (attributes) ->
       @createProperty("doorNumber")
       @createProperty("rooms", ViewFirst.OneToMany)
       @createProperty("postman", ViewFirst.ManyToOne)
      