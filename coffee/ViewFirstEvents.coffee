define ->

  class ViewFirstEvents
  
    @_staticEvents: {}

    @_getOrCreate: (eventName, from, dflt) ->
    
      from[eventName] = dflt unless from[eventName]?
      return from[eventName]
    
    @on: (eventName, func) ->
    
      eventsForClass = ViewFirstEvents._getOrCreate(@.name, ViewFirstEvents._staticEvents, {})
      funcs = ViewFirstEvents._getOrCreate(eventName, eventsForClass, [])
      funcs.push(func)
    
    @fire: (eventName) ->
    
      eventsForClass = ViewFirstEvents._getOrCreate(@.name, ViewFirstEvents._staticEvents, {})
      funcs = ViewFirstEvents._getOrCreate(eventName, eventsForClass, [])
      func() for func in funcs
      
    on: (eventName, func) ->
      
      @_events = [] unless @_events?
      funcs = ViewFirstEvents._getOrCreate(eventName, @_events, [])
      funcs.push(func)
      
    fire: (eventName, other...) ->
    
      @_events = [] unless @_events?
      funcs = ViewFirstEvents._getOrCreate(eventName, @_events, [])
      func.apply(this, other) for func in funcs    
    