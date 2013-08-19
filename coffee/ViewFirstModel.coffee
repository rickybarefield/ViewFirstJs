define ["underscore", "jquery", "Property", "ViewFirstEvents", "AtmosphereSynchronization"], (_, $, Property, Events, Sync) ->

  class Collection extends Events

    constructor: () ->

      super
      @instances = {}

    getAll: ->

      value for key, value of @instances

    size: -> Object.keys(@instances).length

    add: (model, silent = false) ->

      @instances[model.clientId] = model
      @trigger("add", model) unless silent

    remove: (model) ->

      delete @instances[model.clientId]
      @trigger("remove", model)

  class ClientFilteredCollection extends Collection

    constructor: (@serverSyncCollection) ->

      super

    deactivate: =>

      @serverSyncCollection.removeFilteredCollection(@)

  class ServerSynchronisedCollection extends Collection

    constructor: (@modelType, @url) ->

      super
      @url = modelType.url unless @url
      @filteredCollections = []

    filter: (filter) =>

      filteredCollection = new ClientFilteredCollection(@)
      filteredCollectionObject = {collection: filteredCollection, filter: filter}
      @filteredCollections.push filteredCollectionObject
      filteredCollection.add(model, true) for key, model of @instances when filter(model)
      return filteredCollection

    removeFilteredCollection: (collections...) =>

       @filteredCollections = _.filter(@filteredCollections, (collObj) -> (collObj in collections))

    add: (model, silent = false) ->

      super
      filteredCollection.collection.add(model) for filteredCollection in @filteredCollections when filteredCollection.filter(model)

      model.on "change", =>

        for filteredCollection in @filteredCollections

          matches = filteredCollection.filter(model)

          filteredCollection.collection.add(model, silent) if matches and not filteredCollection.collection.instances[model.clientId]?
          filteredCollection.collection.remove(model) if not matches and filteredCollection.collection.instances[model.clientId]?

    activate: =>

      callbackFunctions =
        create: (json) =>
          model = @modelType.load(json)
          @add(model)
        update: (json) =>
          @modelType.load(json)
        delete: (json) =>
          @modelType.load(json)
          throw "delete is not yet implemented"
        remove: (json) =>
          model = @modelType.load(json)
          @remove(model)

      Sync.connectCollection(@url, callbackFunctions)

  class Model extends Events

    @models = {}

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

    isNew: -> !(@isPersisted)

    isPersisted: ->
      @properties["id"].isSet()

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

      callbackFunctions =
        success : @update

      saveFunction = if @isNew() then Sync.persist else Sync.update
      url = if @isNew() then @.constructor.url else @.constructor.url + "/" + @get("id")
      json = JSON.stringify(@asJson())
      saveFunction(url, json, callbackFunctions)

    delete: ->

      callbackFunctions =
        success : ->
          console.log("TODO will need to trigger an event")
        
      Sync.delete(@.constructor.url + "/" + @get("id"), callbackFunctions)
      
      
    update: (json, clean = true) =>
    
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

    ensureModelValid = (Model) ->

      throw "url must be set as a static property" unless Model.url

    @extend: (Child) ->

      ensureModelValid(Child)

      ChildExtended = ->
        Model.apply(this, arguments)
        Child.apply(this, arguments)
        @constructor.instances.push @
        @constructor.trigger("created", @)
        return this

      ChildExtended.modelName = Child.name
      @models[Child.name] = ChildExtended

      Surrogate = ->
      Surrogate.prototype = @prototype

      ChildExtended.prototype = new Surrogate
      ChildExtended.prototype.constructor = ChildExtended
      
      _.extend(ChildExtended, new Events)
      _.extend(ChildExtended, Child)
      _.extend(ChildExtended.prototype, Child.prototype)

      addInstances ChildExtended
      addLoadMethod ChildExtended
      addCreateCollectionFunction ChildExtended

      return ChildExtended

  return Model

  