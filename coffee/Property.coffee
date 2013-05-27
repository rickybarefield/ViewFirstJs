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

    setFromJson: (json) ->
      @set(json)

    add: ->
      throw("Cannot call add on a basic property")

    #Called before the model is saved
    preSave: =>

    addToJson: (json) =>
      if @value?
        json[@name] = @value
      
      