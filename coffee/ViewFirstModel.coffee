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

      onSuccess = (jsonString, successCode, somethingElse) =>
        @update(JSON.parse(jsonString))

      @assertUrl()
      @preSave()
      json = @asJson()
      $.ajax(@_getPluralUrl(), {type: @_getSaveHttpMethod(), data: json, success: onSuccess}) 
      console.log JSON.stringify(json)
      
    update: (json) ->
    
      for key, value of json
        @properties[key].setFromJson(value)

    _getSaveHttpMethod: ->
      if @isNew then "POST" else "PUT"

    _getPluralUrl: ->
      @url + "s"
      
    assertUrl: ->
      throw("url must be defined for model") unless @url?