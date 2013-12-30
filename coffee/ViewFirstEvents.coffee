module.exports = class ViewFirstEvents
  
  lastIdUsed: 0

  constructor: ->
    @events = {}

  getNextId = ->

    @lastIdUsed = @lastIdUsed + 1

  getFuncsObjectForEvent = (eventName) ->

    @events[eventName] = {} unless @events[eventName]?
    @events[eventName]

  on: (eventName, func) ->

    id = getNextId.call(this)
    funcs = getFuncsObjectForEvent.call(this, eventName)
    funcs[id] = func
    return {off: -> delete funcs[id]}


  trigger: (eventName, other...) ->

    funcs = getFuncsObjectForEvent.call(this, eventName)
    func.apply(this, other) for key, func of funcs
