define ["underscore", "jquery", "Property", "ViewFirstEvents", "AtmosphereSynchronization"], (_, $, Property, Events, Sync) ->

  class ClientFilteredCollection extends Events

    constructor: () ->

      @instances = {}

    add: (model, silent = false) ->

      @instances[model.clientId] = model
      @trigger("add", model) unless silent

  class ServerSynchronisedCollection extends Events

    constructor: (@modelType, @url) ->

      super
      @url = modelType.url unless @url
      @filteredCollections = []
      @instances = {}

    filter: (filter) ->

      filteredCollection = new ClientFilteredCollection
      filteredCollectionObject = {collection: filteredCollection, filter: filter}
      @filteredCollections.push filteredCollectionObject
      filteredCollection.add(model, true) for model in @instances when filter(model)

    activate: =>

      callbackFunctions =
        create: (json) =>
          model = @modelType.load(json)
          @instances[model.clientId] = model
        update: (json) =>
          @modelType.load(json)
        delete: (json) =>
          @modelType.load(json)
          throw "delete is not yet implemented"
        remove: (json) =>
          model = @modelType.load(json)
          delete @instances[model.clientId]

      Sync.connectCollection(@url, callbackFunctions)

    getAll: ->
    
      value for key, value of @instances

    modelAdded = (model, silent = false) ->
    
        @instances[model.clientId] = model

        #TODO Need to consider how to listen for model changes and reevaluate filters, would
        #TODO be easier to let filtered collections take care of themselves but this would
        #TODO exclude the idea of a move event, so need to know if a model is in a collection

        @trigger("add", model) unless silent

    size: -> Object.keys(@instances).length
    
  class Model extends Events

    constructor: () ->

      super
      @properties = {}
      @clientId = createClientId()
      idProperty = @createProperty("id", Number)
      idProperty.on "change", (oldValue, newValue) =>
                                      if oldValue? then throw "Cannot set id as it has already been set"
                                      if @constructor.instancesById[newValue]? then throw "Cannot set the id to #{newValue} as another object has that id"
                                      @constructor.instancesById[newValue] = this


    lastClientIdUsed = 0

    createClientId = ->
    
      lastClientIdUsed = lastClientIdUsed + 1

      
    createProperty: (name, type, relationship) ->
      property = new Property(name, type, relationship)
      property.on("change", => @trigger("change"))
      @properties[name] = property
      return property

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
      Child.instancesById = {}

    addLoadMethod = (Child) ->
      Child.load = (json) ->
        id = json.id
        childObject = if Child.instancesById[id]? then Child.instancesById[id] else new Child
        childObject.update(json)
        return childObject

    addCreateCollectionFunction = (Child) ->
      Child.createCollection = (url) ->
        new ServerSynchronisedCollection(Child, url)

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
      
      _.extend(ChildExtended, new Events)
      _.extend(ChildExtended, Child)
      
      addInstances ChildExtended
      addLoadMethod ChildExtended
      addCreateCollectionFunction ChildExtended

      ChildExtended.prototype[key] = Child.prototype[key] for key of Child.prototype when Child.prototype.hasOwnProperty(key)
      
      return ChildExtended
      
    
    _getSaveHttpMethod: ->
      if @isNew() then "POST" else "PUT"

    _getSaveUrl: ->
      @url + if !@isNew() then "/" + @get("id") else ""
      
    _assertUrl: ->
      throw("url must be defined for model") unless @url?

  return Model

  