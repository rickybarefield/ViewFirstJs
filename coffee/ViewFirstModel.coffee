_ = require("./underscore-dep")
$ = require('./jquery-dep')
Events = require("./ViewFirstEvents")
Sync = require("./ScrudSync")
Property = require("./Property")
ServerSynchronisedCollection = require("./ServerSynchronisedCollection")

module.exports = class Model extends Events

  @models = {}
  @find: (modelType, id) -> @models[modelType].instancesById[id]

  lastClientIdUsed = 0
  createClientId = -> lastClientIdUsed = lastClientIdUsed + 1

  constructor: () ->

    super
    @properties = {}
    @clientId = createClientId()
    idProperty = @createProperty("id", Number)
    idProperty.on "change", (oldValue, newValue) =>
                                    if oldValue? then throw "Cannot set id as it has already been set"
                                    if @constructor.instancesById[newValue]? then throw "Cannot set the id to #{newValue} as another object has that id"
                                    @constructor.instancesById[newValue] = this

  createProperty: (name, type, relationship) ->
    property = new Property(name, type, relationship)
    property.on("change", => @trigger("change"))
    @properties[name] = property
    return property

  get: (name) -> @properties[name].get()
  getProperty: (name) -> @properties[name]
  set: (name, value) -> @properties[name].set(value)
  add: (name, value) -> @properties[name].add(value)
  removeAll: (name) -> @properties[name].removeAll()

  findProperty: (key) ->

    elements = key.split(".")
    current = this
    for element in elements
      current = @getProperty(element)
    return current

  onPropertyChange: (propertyName, func) ->
    @properties[propertyName].on("change", func)

  asJson: (includeOnlyDirtyProperties = true) ->

    json = {}
    property.addToJson(json, includeOnlyDirtyProperties) for key, property of @properties when !includeOnlyDirtyProperties or property.isDirty or property.name == "id"
    return json

  save: =>

    isPersisted = -> @properties["id"].isSet()

    callbackFunctions =
      success : @update

    saveFunction = if isPersisted() then @sync.update else @sync.persist
    json = JSON.stringify(@asJson())
    saveFunction(json, callbackFunctions)

  delete: =>

    callbackFunctions =
      success : ->
        console.log("TODO will need to trigger an event")

    @sync.delete(@get("id"), callbackFunctions)


  update: (json, clean = true) =>

    for key, value of json
      @properties[key].setFromJson(value, clean = true)

  @extend: (Child) ->

    ensureModelValid = (Model) -> throw "type must be set as a static property: #{Model}" unless Model.type

    addLoadMethod = (Child) ->
      Child.load = (json) ->
        id = json.id
        childObject = if Child.instancesById[id]? then Child.instancesById[id] else new Child
        childObject.update(json)
        return childObject

    addInstances = (Child) ->
      Child.instances = []
      Child.instancesById = {}

    addCreateCollectionFunction = (Child) ->
      Child.createCollection = ->
        new ServerSynchronisedCollection(Child)

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
