define ["underscore", "jquery", "Property", "ViewFirstEvents"], (_, $, Property, Events) ->

  class Collection
  

    constructor: (@currentModels, modelType, @instances = []) ->
      
      Events.on.call(modelType, "created", (model) => @_modelAdded(model))
      @_modelAdded(model) for model in currentModels

    getAll: ->
    
      @instances.slice(0)

    _modelAdded: (model) ->
    
      @instances.push(model)
    
    size: -> @instances.length
    
  class Model extends Events

    @instances = {}
    
    @getOrCreateInstances: (modelName) ->
    
      @instances[modelName] = [] unless @instances[modelName]
      @instances[modelName]
    
    constructor: (@properties = {}) ->

      Model.getOrCreateInstances(@constructor.name).push(@)
      @createProperty("id")
      Events.fire.call(@constructor, "created")
      
      
    createProperty: (name, relationship) ->
      @properties[name] = new Property(name, relationship)

    isNew: ->
      !@properties["id"].isSet()

    get: (name) ->
      @properties[name].get()
      
    getProperty: (name) ->
      @properties[name]
      
    findProperty: (key) ->
    
      elements = key.split(".")
      current = this
      for element in elements
        current = @getProperty(element)
      return current
      
      
    set: (name, value) ->
      @properties[name].set(value)

    add: (name, value) ->
      @properties[name].add(value)

    removeAll: (name) ->
      @properties[name].removeAll()
      
    onPropertyChange: (propertyName, func) ->
      @properties[propertyName].on("change", func)

    asJson: (includeOnlyDirtyProperties = true) ->
    
      json = {}
      property.addToJson(json, includeOnlyDirtyProperties) for key, property of @properties when !includeOnlyDirtyProperties or property.isDirty or property.name == "id"
      return json

    save: =>

      onSuccess = (jsonString, successCode, somethingElse) =>
        @update(JSON.parse(jsonString))

      @_assertUrl()
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

    @createCollection: () ->
      new Collection(Model.getOrCreateInstances(@name), @)

    _getSaveHttpMethod: ->
      if @isNew() then "POST" else "PUT"

    _getSaveUrl: ->
      @url + "s" + if !@isNew() then "/" + @get("id") else ""
      
    _assertUrl: ->
      throw("url must be defined for model") unless @url?
      

  
  return Model