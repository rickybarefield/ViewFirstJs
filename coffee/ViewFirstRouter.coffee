_ = require("./underscore-dep")
ViewFirstModel = require("./ViewFirstModel")

module.exports = class ViewFirstRouter

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

      #TODO Need to work on this, looks to be in the wrong order, i.e. load named models then render view
      #TODO also loading individual models is not yet supported by Scrud so work to be done there.

      if namedModelStrings? && namedModelStrings != ""

        for namedModelString in namedModelStrings.split("|")
          parsedString = namedModelRegex.exec(namedModelString)
          modelName = parsedString[1]
          modelType = parsedString[2]
          modelId = parsedString[3]

          @viewFirst.setNamedModel(modelName, ViewFirstModel.find(modelType, modelId))

  refresh: => handleBackButton.call(@)

  initialize: =>

    @backButtonCallback = => handleBackButton.call(@)

    window.addEventListener "popstate", @backButtonCallback

  destroy: =>

    window.removeEventListener "popstate", @backButtonCallback

  deriveNamedModelString = (namedModels) ->

    namedModelStrings = ("#{name}=#{container.model.constructor.modelName}!#{container.model.get("id")}" for name, container of namedModels when (container?.model?.isPersisted? && container.model.isPersisted()))
    return namedModelStrings.join("|")

  update: ->

    namedModelString = deriveNamedModelString(@viewFirst.namedModels)

    namedModelString = "|" + namedModelString if namedModelString != ""

    history.pushState(null, null, "#{@baseUrl}##{@viewFirst.currentView}#{namedModelString}")
