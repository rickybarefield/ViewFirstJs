define ["ViewFirstEvents"], (Events) ->

  class ViewFirstModelContainer extends Events

    constructor: () ->

    set: (model) ->
      oldModel = @model
      @model = model
      @trigger("change", oldModel, @model)

