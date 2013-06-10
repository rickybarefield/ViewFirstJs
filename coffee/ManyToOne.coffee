define ->

  class ManyToOne
  
    addToJson: (json) ->
      json[@name] = {id: @value.get("id")}

    setFromJson: (json, clean) ->
      @isDirty = !clean
      @value.update(json)
  
    getProperty: (name) ->
      @value.getProperty(name)