define ["underscore", "jquery", "Property", "ViewFirstEvents"], (_, $, Property, Events) ->

  class Collection extends Events

    constructor: (@currentModels, modelType, @instances = []) ->
      
      Events.on.call(modelType, "created", (model) => @_modelAdded(model))
      @_modelAdded(model, true) for model in currentModels

    getAll: ->
    
      @instances.slice(0)

    _modelAdded: (model, silent = false) ->
    
      @instances.push(model)
      @fire("add", model) unless silent
    
    size: -> @instances.length
    
  class Model extends Events

    @instances = {}
    
    @getOrCreateInstances: (modelName) ->
    
      @instances[modelName] = [] unless @instances[modelName]
      @instances[modelName]
    
    constructor: (@properties = {}) ->

      Model.getOrCreateInstances(@constructor.name).push(@)
      @createProperty("id")
      Events.fire.call(@constructor, "created", @)
      
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

    save: ->

      onSuccess = (jsonString, successCode, somethingElse) =>
        @update(JSON.parse(jsonString))

      @_assertUrl()
      json = @asJson()
      $.ajax(@_getSaveUrl(), {type: @_getSaveHttpMethod(), data: json, success: onSuccess}) 
      console.log JSON.stringify(json)

    delete: ->
    
      onSuccess = (jsonString, successCode, somethingElse) =>
        console.log("TODO will need to trigger an event")
        
      $.ajax(@_getSaveUrl(), {type: "DELETE", success: onSuccess}) 
      
      
    update: (json, clean = true) ->
    
      for key, value of json
        @properties[key].setFromJson(value, clean = true)

    @createCollection: () ->
      new Collection(Model.getOrCreateInstances(@name), @)

    @extend: (child) =>

      child[key] = this[key] for key of this when _.has(this, key)
      
      childOrigPrototype = child.prototype
      
      Surrogate = () -> 
        
      
      Surrogate.prototype = this.prototype
      child.prototype = new Surrogate
      child.prototype.constructor = child
    
      child.prototype[key] = childOrigPrototype[key] for key of childOrigPrototype when _.has(childOrigPrototype, key)
        
    
      child.__super__ = @prototype;
      
      return child

    _getSaveHttpMethod: ->
      if @isNew() then "POST" else "PUT"

    _getSaveUrl: ->
      @url + "s" + if !@isNew() then "/" + @get("id") else ""
      
    _assertUrl: ->
      throw("url must be defined for model") unless @url?
      

  
  return Model
  
  ###
    function(child, parent)
    {
      for (var key in parent)
      {
        if (__hasProp.call(parent, key))
        {
          child[key] = parent[key];
        }
      }
      
      function ctor()
      {
        this.constructor = child;
      }
      
      ctor.prototype = parent.prototype;
      child.prototype = new ctor();
      child.__super__ = parent.prototype;
      
      return child;
    };
   ###

  