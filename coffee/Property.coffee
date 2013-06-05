define ["underscore"], (_) ->

  class Property
  
    value: null
    isDirty: true
    
    constructor: (@name, relationship, @type) ->
    
      if relationship?
        _.extend(@, new relationship())

    get: ->
      @value

    set: (value) ->
      @isDirty = true
      @value = value
      
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
      
      