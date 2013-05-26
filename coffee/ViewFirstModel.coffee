define ["Property"], (Property) ->

  class Model
    
    @instances: {}
    
    constructor: (@properties = {}, @isNew = true) ->
      @createProperty("id")
    
    createProperty: (name, relationship) ->
    
      @properties[name] = new Property(name, relationship)

    get: (name) ->
    
      @properties[name].get()
      

    set: (name, value) ->
    
      @properties[name].set(value)

    add: (name, value) ->
    
      @properties[name].add(value)

    asJson: ->
    
      json = {}
      property.addToJson(json) for key, property of @properties      
      return json

    preSave: ->
    
       property.preSave for property in @properties
    
    save: =>

      @preSave
      json = @asJson()
      console.log JSON.stringify(json)
