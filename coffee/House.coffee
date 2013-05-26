define ["ViewFirst", "Room", "Postman"], (ViewFirst) ->

  class House extends ViewFirst.Model
  
    constructor: (attributes) ->
      super()
      @createProperty("doorNumber")
      @createProperty("rooms", ViewFirst.OneToMany)
      @createProperty("postman", ViewFirst.ManyToOne)
      