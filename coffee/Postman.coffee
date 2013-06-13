define ["ViewFirst"], (ViewFirst) ->

  ViewFirst.Model.extend class Postman
  
    constructor: ->
      super()
      @createProperty("name")    

