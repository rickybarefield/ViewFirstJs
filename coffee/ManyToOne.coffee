define ->

  class ManyToOne
  
    addToJson: (json) ->
      json[@name] = {id: @value.get("id")}
  