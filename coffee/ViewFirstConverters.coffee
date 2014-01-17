###

  TODO not keen on this class as adding to basic type prototypes means you
  TODO could never have two ViewFirsts initialised, although I don't particularly
  TODO see the point in having two, it could lead to really hard to find bugs

###
moment = require("./moment")

module.exports = (viewFirst) ->

    String._viewFirstConvert = (value) ->

      if typeof value == "string" || value instanceof String
        value
      else
        value.toString()

    String.fromJson = String._viewFirstConvert

    String.prototype._viewFirstToString = -> this.toString()

    Number._viewFirstConvert = (value) ->

      if typeof value == "number" || value instanceof Number
        value
      else if typeof value == "string" || value instanceof String
        parseFloat(value)
      else
        throw "Unable to convert #{value} to a number"

    Number.fromJson = Number._viewFirstConvert

    Number.prototype._viewFirstToString = ->

      this.toString()

    Date._viewFirstConvert = (value) ->

      if value instanceof Date
        value
      else if typeof value == "number" || value instanceof Number
        new Date(value)
      else if typeof value == "string" || value instanceof String
        if value == "" then null else moment(value, viewFirst.dateFormat).toDate()
      else
        throw "Unable to convert #{value} to a Date"

    Date.fromJson = (json) -> new Date(json)

    Date.prototype._viewFirstToString = ->

      moment(this).format(viewFirst.dateFormat)

    Date.prototype.setMonthOfYear = (value) ->

      @setMonth(value - 1)

    Date.prototype.getMonthOfYear = ->

      @getMonth() + 1