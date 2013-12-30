moment = require("./moment")

module.exports = (viewFirst) ->

    String._viewFirstConvert = (value) ->

      if typeof value == "string" || value instanceof String
        value
      else
        value.toString()


    String.prototype._viewFirstToString = -> this.toString()

    Number._viewFirstConvert = (value) ->

      if typeof value == "number" || value instanceof Number
        value
      else if typeof value == "string" || value instanceof String
        parseFloat(value)
      else
        throw "Unable to convert #{value} to a number"


    Number.prototype._viewFirstToString = ->

      this.toString()

    Date._viewFirstConvert = (value) ->

      if value instanceof Date
        value
      else if typeof value == "number" || value instanceof Number
        new Date(value)
      else if typeof value == "string" || value instanceof String
        moment(value, viewFirst.dateFormat).toDate()
      else
        throw "Unable to convert #{value} to a Date"

    Date.prototype._viewFirstToString = ->

      moment(this).format(viewFirst.dateFormat)