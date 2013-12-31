_ = require("./underscore-dep")

module.exports = class OneToMany

  constructor: (@value = []) ->

  addToJson: (json) ->
    json[@name] = (model.asJson() for model in @value)

  add: (value) ->
    @value.push value

  removeAll: ->
    @value.length = 0

  setFromJson: (json, clean) ->
      @isDirty = !clean
      for pair in _.zip(@value, json)
        pair[0].update(pair[1], clean)