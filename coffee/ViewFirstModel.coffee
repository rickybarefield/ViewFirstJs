define ["jquery", "Property"], ($, Property) ->

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

      @assertUrl()
      @preSave()
      json = @asJson()
      $.ajax(@_getPluralUrl(), {type: @_getSaveHttpMethod(), data: json}) 
      console.log JSON.stringify(json)

    _getSaveHttpMethod: ->
      if @isNew then "POST" else "PUT"

    _getPluralUrl: ->
      @url + "s"
      
    assertUrl: ->
      throw("url must be defined for model") unless @url?