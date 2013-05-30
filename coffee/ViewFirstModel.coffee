define ["jquery", "Property"], ($, Property) ->

  class Model
    
    @instances: {}
    
    constructor: (@properties = {}) ->
      @createProperty("id")
    
    createProperty: (name, relationship) ->
    
      @properties[name] = new Property(name, relationship)

    isNew: ->
      !@_getProperty("id").isSet()

    get: (name) ->
    
      @_getProperty(name).get()
      
    _getProperty: (name) -> @properties[name]

    set: (name, value) ->
    
      @properties[name].set(value)

    add: (name, value) ->
    
      @properties[name].add(value)

    asJson: (includeOnlyDirtyProperties = true) ->
    
      json = {}
      property.addToJson(json, includeOnlyDirtyProperties) for key, property of @properties when !includeOnlyDirtyProperties or property.isDirty or property.name == "id"
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
      
    update: (json, clean = true) ->
    
      for key, value of json
        @properties[key].setFromJson(value, clean = true)

    _getSaveHttpMethod: ->
      if @isNew() then "POST" else "PUT"

    _getPluralUrl: ->
      @url + "s"
      
    assertUrl: ->
      throw("url must be defined for model") unless @url?