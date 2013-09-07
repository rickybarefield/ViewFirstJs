define ["ViewFirstModel", "underscore"], (ViewFirstModel, _) ->

  class ViewFirstRouter

    constructor: (@viewFirst) ->

      @baseUrl = location.protocol + '//' + location.host + location.pathname

    locationRegex = /#([^|]*)\|?(.*)/
    namedModelRegex = /([^=]*)=([^!]*)!(.*)/

    handleBackButton = (event) ->

      matches = locationRegex.exec(location.hash)

      viewName = matches[1]
      namedModelStrings = matches[2]

      if viewName?
        @viewFirst.render(viewName)

        if namedModelStrings?

          for namedModelString in namedModelStrings.split("|")
            parsedString = namedModelRegex.exec(namedModelString)
            modelName = parsedString[1]
            modelType = parsedString[2]
            modelId = parsedString[3]

            @viewFirst.setNamedModel(modelName, ViewFirstModel.find(modelType, modelId))

    initialize: =>

      @backButtonCallback = => handleBackButton.call(@)

      window.addEventListener "popstate", @backButtonCallback

    destroy: =>

      window.removeEventListener "popstate", @backButtonCallback

    deriveNamedModelString = (namedModels) ->

      namedModelStrings = ("#{name}=#{container.model.constructor.modelName}!#{container.model.get("id")}" for name, container of namedModels when container.model.isPersisted())
      return namedModelStrings.join("|")

    update: ->

      namedModelString = deriveNamedModelString(@viewFirst.namedModels)

      namedModelString = "|" + namedModelString if namedModelString != ""

      history.pushState(null, null, "#{@baseUrl}##{@viewFirst.currentView}#{namedModelString}")
