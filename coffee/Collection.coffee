Events = require("./ViewFirstEvents")

module.exports = class Collection extends Events

  constructor: () ->

    super
    @instances = {}

  getAll: ->

    value for key, value of @instances

  size: -> Object.keys(@instances).length

  add: (model, silent = false) ->

    if(@instances[model.clientId]?) then return false
    @instances[model.clientId] = model
    @trigger("add", model) unless silent
    return true

  remove: (model) ->

    delete @instances[model.clientId]
    @trigger("remove", model)
