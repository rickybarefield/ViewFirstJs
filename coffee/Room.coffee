define ["ViewFirst"], (ViewFirst) ->
  
  class Room extends ViewFirst.Model

    constructor: ->
      super()
      @createProperty("colour")
      @createProperty("size")    

    url: "room"  