_ = require("underscore")
Events = require("./ViewFirstEvents")

module.exports = class Property extends Events

  value: null
  isDirty: true

  constructor: (@name, @type, relationship) ->
    super
    if relationship?
      _.extend(@, new relationship())

  get: ->
    @value

  toString: ->

    return null unless @value?
    return @value._viewFirstToString() if @value._viewFirstToString?
    throw "Unable to convert #{@value} to string"

  getProperty: ->
    throw "Cannot get a property for this type of relationship"

  convert = (value) ->

    if !value? || value.constructor == @type
      value
    else
      converter = @type._viewFirstConvert
      throw "Unable to set type.  There are no converters defined for #{@type.name}" unless converter?
      converter(value)

  set: (value) ->
    oldValue = @value
    @isDirty = true
    @value = convert.call(this, value)
    if oldValue != @value
      @trigger("change", oldValue, @value)


  isSet: -> @value?

  setFromJson: (json, clean) ->
    @set(json)
    @isDirty = !clean

  add: ->
    throw("Cannot call add on a basic property")

  removeAll: ->
    throw("Cannot call removeAll on a basic property")

  addToJson: (json) =>
    if @value?
      json[@name] = @value
