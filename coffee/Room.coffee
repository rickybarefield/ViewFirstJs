define ["ViewFirst"], (ViewFirst) ->
  
  ViewFirst.Model.extend class Room

    constructor: ->
      super()
      @createProperty("colour")
      @createProperty("size")    

    url: "room"
   
  return Room