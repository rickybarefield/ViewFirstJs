define ["ViewFirst"], (ViewFirst) ->

  class Postman extends ViewFirst.Model
  
    constructor: ->
      super()
      @createProperty("name")    

