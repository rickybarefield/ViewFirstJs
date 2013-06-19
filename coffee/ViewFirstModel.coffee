define ["underscore", "jquery", "Property", "ViewFirstEvents"], (_, $, Property, Events) ->

  class Collection extends Events

    constructor: (modelType, @filter = -> true) ->
      
      super
      @instances = {}
      @changeTriggers = {}
      modelType.on("created", (model) => modelAdded.call(this, model))
      modelAdded.call(this, model, true) for model in modelType.instances

    getAll: ->
    
      value for key, value of @instances

    removeCurrentChangeTrigger = (model) ->

      currentChangeTrigger = @changeTriggers[model.clientId]
      currentChangeTrigger.off() if currentChangeTrigger?
    

    modelAdded = (model, silent = false) ->
    
      if(@filter(model))
        @instances[model.clientId] = model
        removeCurrentChangeTrigger.call(this, model)
        @changeTriggers[model.clientId] = model.on("change", => checkModelStillMatches.call(this, model))
        @trigger("add", model) unless silent
      else
        @changeTriggers[model.clientId] = model.on("change", => modelAdded.call(this, model)) unless @changeTriggers[model.clientId]?

    checkModelStillMatches = (model) ->
      
      if(!@filter(model))
      
        delete @instances[model.clientId]
        removeCurrentChangeTrigger.call(this, model)
        @changeTriggers[model.clientId] = model.on("change", => @modelAdded.call(this, model))
        @trigger("remove", model)

    size: -> Object.keys(@instances).length
    
  class Model extends Events

    constructor: (@properties = {}) ->

      super
      @clientId = createClientId()
      @createProperty("id")

    lastClientIdUsed = 0

    createClientId = ->
    
      lastClientIdUsed = lastClientIdUsed + 1

      
    createProperty: (name, relationship) ->
      property = new Property(name, relationship)
      property.on("change", => @trigger("change"))
      @properties[name] = property

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
      Child.createCollection = (filter) ->
        new Collection(Child, filter)

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

  