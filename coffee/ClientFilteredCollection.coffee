Collection = require("./Collection")

module.exports = class ClientFilteredCollection extends Collection

  constructor: (@serverSyncCollection) ->

    super

  deactivate: =>

    @serverSyncCollection.removeFilteredCollection(@)
