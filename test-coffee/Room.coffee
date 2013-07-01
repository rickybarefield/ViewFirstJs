define ["ViewFirst"], (ViewFirst) ->
  
  ViewFirst.Model.extend class Room

    url: "rooms"

    constructor: ->
      @createProperty("colour")
      @createProperty("size")    

