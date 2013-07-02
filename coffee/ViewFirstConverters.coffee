define ->

  ViewFirstConverters = (viewFirst) ->

    String._viewFirstConvert = (value) ->

      if typeof value == "string" || value instanceof String
        value
      else
        value.toString()

    Number._viewFirstConvert = (value) ->

      if typeof value == "number" || value instanceof Number
        value
      else if typeof value == "string" || value instanceof String
        parseFloat(value)
      else
        throw "Unable to convert #{value} to a number"

    Date._viewFirstConvert = (value) ->

      if value instanceof Date
        value
      else if typeof value == "number" || value instanceof Number
        new Date(value)
      else
        throw "Unable to convert #{value} to a Date"