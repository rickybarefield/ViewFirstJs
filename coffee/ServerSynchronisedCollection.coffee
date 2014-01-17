Collection = require("./Collection")
ClientFilteredCollection = require("./ClientFilteredCollection")

module.exports = class ServerSynchronisedCollection extends Collection

  constructor: (@modelType) ->

    super
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

    if(super)
      filteredCollection.collection.add(model) for filteredCollection in @filteredCollections when filteredCollection.filter(model)

      model.on "change", =>

        for filteredCollection in @filteredCollections

          matches = filteredCollection.filter(model)

          filteredCollection.collection.add(model, silent) if matches and not filteredCollection.collection.instances[model.clientId]?
          filteredCollection.collection.remove(model) if not matches and filteredCollection.collection.instances[model.clientId]?
      return true
    else
      return false

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

    Sync.connectCollection(@modelType.type, callbackFunctions)
