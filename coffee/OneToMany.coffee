define ->

  class OneToMany
  
    constructor: (@value = []) ->
  
    addToJson: (json) ->
        json[@name] = (model.asJson() for model in @value)

    add: (value) ->
      @value.push value