class window.ViewFirstRouter extends Backbone.Router

  constructor: (@viewFirst) ->

  addRoute: (pageName, index = false) =>

    createRegex = (pageName) -> new RegExp("^#{pageName}/?([/A-Za-z!0-9]*)$")

    routingFunction = (serializedModels) =>
      console.log "Routing to #{pageName}"
      @currentPage = pageName
      @viewFirst.namedModels = {}
      @viewFirst.renderView pageName

      for serializedModel in serializedModels.split("/") when serializedModels? and serializedModels != ""
        do (serializedModel) =>
          serializedParts = serializedModel.split ("!")
          clazz = window[serializedParts[1]]
          id = parseInt(serializedParts[2])
          model = if clazz.findOrCreate? then clazz.findOrCreate({id: id}) else new clazz({id: id})
          model.fetch
            success: => @viewFirst.setNamedModel(serializedParts[0], model, true)
          console.log model.get("description") + "with id: " + model.get("id")
          
    console.log "Adding a route to #{pageName}"

    @route(createRegex(pageName), pageName, routingFunction)
    if index then @route("", "index", =>
      console.log "navy"
      @navigate pageName, true)

  updateState: =>

    namedModels = @viewFirst.namedModels
    modelsSerialized = for key of namedModels when namedModels[key].id?
      do (key) ->
        "/#{key}!#{namedModels[key].constructor.name}!#{namedModels[key].id}"

    url = @currentPage + modelsSerialized.join("")
    @navigate url