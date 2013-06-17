define ->

  class ViewFirstEvents

    constructor: () ->
      this.events = []

    getOrCreate = (eventName, from, dflt) ->
  
      from[eventName] = dflt unless from[eventName]?
      return from[eventName]
  
    on: (eventName, func) ->
  
      @_events = [] unless @_events?
      funcs = getOrCreate(eventName, @_events, [])
      funcs.push(func)
      
    trigger: (eventName, other...) ->
    
      @_events = [] unless @_events?
      funcs = getOrCreate(eventName, @_events, [])
      func.apply(this, other) for func in funcs
       