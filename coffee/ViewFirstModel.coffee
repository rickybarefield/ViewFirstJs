define ["underscore", "jquery", "Property", "ViewFirstEvents"], (_, $, Property, Events) ->

  class Collection extends Events

    constructor: (modelType, @instances = []) ->
      
      modelType.on("created", (model) => @_modelAdded(model))
      @_modelAdded(model, true) for model in modelType.instances

    getAll: ->
    
      @instances.slice(0)

    _modelAdded: (model, silent = false) ->
    
      @instances.push(model)
      @trigger("add", model) unless silent
    
    size: -> @instances.length
    
  class Model extends Events

    constructor: (@properties = {}) ->

      @createProperty("id")
      
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

    addInstances = (Child) ->
      Child.instances = []

    addCreateCollectionFunction = (Child) ->
      Child.createCollection = ->
        new Collection(Child)

    @extend: (Child) ->

      ChildExtended = ->
        Model.apply(this, arguments)
        Child.apply(this, arguments)
        @constructor.instances.push @
        @constructor.trigger("created", @)
        return this

      Surrogate = ->
      Surrogate.prototype = @prototype

      ChildExtended.prototype = new Surrogate
      ChildExtended.prototype.constructor = ChildExtended
      #ChildExtended.prototype.constructor.name = Child.constructor.name
      
      _.extend(ChildExtended, new Events)
      
      addInstances ChildExtended
      addCreateCollectionFunction ChildExtended

      ChildExtended.prototype[key] = Child.prototype[key] for key of Child.prototype when Child.prototype.hasOwnProperty(key)
      
      return ChildExtended
      
    
    _getSaveHttpMethod: ->
      if @isNew() then "POST" else "PUT"

    _getSaveUrl: ->
      @url + "s" + if !@isNew() then "/" + @get("id") else ""
      
    _assertUrl: ->
      throw("url must be defined for model") unless @url?
      

  
  return Model

  