define ["ViewFirst"], (ViewFirst) ->
  
  ViewFirst.Model.extend class Room

    @type: "room"

    constructor: ->
      @createProperty("colour", String)
      @createProperty("size", Number)

