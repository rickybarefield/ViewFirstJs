define ["ViewFirst"], (ViewFirst) ->
  
  ViewFirst.Model.extend class Room

    constructor: ->
      @createProperty("colour")
      @createProperty("size")    

    url: "room"
  