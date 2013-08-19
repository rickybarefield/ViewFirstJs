define ["ViewFirstModel"], (ViewFirstModel) ->

  class ViewFirstRouter

    constructor: (@viewFirst) ->

      @baseUrl = location.protocol + '//' + location.host + location.pathname

    handleBackButton = (state) ->

      alert(state)

    initialize: ->

      window.addEventListener "popstate", handleBackButton

    deriveNamedModelString = (namedModels) ->

      namedModelStrings = ("#{name}=#{container.model.constructor.modelName}!#{container.model.get("id")}" for name, container of namedModels when container.model.isPersisted())
      return namedModelStrings.join("|") if namedModelStrings?

    update: ->

      namedModelString = deriveNamedModelString(@viewFirst.namedModels)
      namedModelString = "|" + namedModelString if namedModelString?

      history.pushState(null, null, "#{@baseUrl}##{@viewFirst.currentView}#{namedModelString}")

    ###

    addRoute: (pageName, index = false) =>
  
      createRegex = (pageName) -> new RegExp("^#{pageName}/?([/A-Za-z!0-9]*)$")
  
      routingFunction = (serializedModels) =>
        console.log "Routing to #{pageName}"
        @currentPage = pageName
        @viewFirst.namedModels = {}
        @viewFirst.renderView pageName
  
        if serializedModels? and serializedModels != ""
          for serializedModel in serializedModels.split("/")
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

    ###