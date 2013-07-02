define ["ViewFirst"], (ViewFirst) ->
  
  ViewFirst.Model.extend class Room

    url: "rooms"

    constructor: ->
      @createProperty("colour", String)
      @createProperty("size", Number)

