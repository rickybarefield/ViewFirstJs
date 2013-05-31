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

    save: =>

      onSuccess = (jsonString, successCode, somethingElse) =>
        @update(JSON.parse(jsonString))

      @assertUrl()
      json = @asJson()
      $.ajax(@_getSaveUrl(), {type: @_getSaveHttpMethod(), data: json, success: onSuccess}) 
      console.log JSON.stringify(json)

    delete: =>
    
      onSuccess = (jsonString, successCode, somethingElse) =>
        console.log("TODO will need to trigger an event")
        
      $.ajax(@_getSaveUrl(), {type: "DELETE", success: onSuccess}) 
      
      
    update: (json, clean = true) ->
    
      for key, value of json
        @properties[key].setFromJson(value, clean = true)

    _getSaveHttpMethod: ->
      if @isNew() then "POST" else "PUT"

    _getSaveUrl: ->
      @url + "s" + if !@isNew() then "/" + @get("id") else ""
      
    assertUrl: ->
      throw("url must be defined for model") unless @url?