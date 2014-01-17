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