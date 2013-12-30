Events = require("./ViewFirstEvents")

module.exports = class ViewFirstModelContainer extends Events

  constructor: () ->
    super

  set: (model) ->
    oldModel = @model
    @model = model
    @trigger("change", oldModel, @model)
