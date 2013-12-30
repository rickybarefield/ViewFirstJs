ViewFirstModel = require("./ViewFirstModel")
ViewFirstRouter = require("./ViewFirstRouter")
ViewFirstModelContainer = require("./ViewFirstModelContainer")
BindHelpers = require("./BindHelpers")
TemplatingSnippets = require("./TemplatingSnippets")
OneToMany = require("./OneToMany")
ManyToOne = require("./ManyToOne")
ViewFirstConverters = require("./ViewFirstConverters")
Sync = require("./ScrudSync")

module.exports = class ViewFirst extends BindHelpers

  _target: "body"

  Models = []

  @Model = ViewFirstModel
  OriginalExtend = @Model.extend

  @Model.extend = (Child) ->

    Extended = OriginalExtend.call(this, Child)
    Models.push Extended
    return Extended

  @OneToMany = OneToMany
  @ManyToOne = ManyToOne

  dateFormat: "DD/MM/YYYY"

  constructor: (url) ->

    sync = new Sync(url)
    @sync = sync

    for Model in Models

      do (Model) =>

        @[Model.modelName] = ->
          Model.apply(this, arguments)
          @sync = sync
          return this

        _.extend(@[Model.modelName], Model)

        @[Model.modelName].prototype = Model.prototype

    @views = {}
    @namedModels = {}
    @snippets = {}
    @router = new ViewFirstRouter(this)
    @addSnippet(key, value) for key, value of TemplatingSnippets
    ViewFirstConverters(@)
    $('script[type="text/view-first-template"]').each (id, el) =>
      node = $(el)
      viewName = node.attr("name")
      @views[viewName] = node.html()
      #TODO @router.addRoute viewName, viewName == @indexView

  initialize: (callback) =>

    @router.initialize()
    @sync.connect(callback)

  render: (viewId) ->

    @currentView = viewId
    viewElement = @views[viewId]
    throw "Unable to find view: #{viewId}" unless viewElement?
    inflated = @inflate(viewElement)
    @router.update()
    $(@_target).html inflated

  refresh: -> @router.refresh()

  addSnippet: (name, func) ->
    @snippets[name] = func

  setNamedModel: (name, model, dontSerialize = false) ->

    @namedModels[name] = new ModelContainer() unless @namedModels[name]?
    modelContainer = @namedModels[name]
    modelContainer.set(model)

    @router.update()

  getNamedModel: (name) ->

    modelContainer = @namedModels[name]
    return if modelContainer? then modelContainer.model else null

  onNamedModelChange: (name, func) ->

    @namedModels[name] = new ModelContainer() unless @namedModels[name]?
    modelContainer = @namedModels[name]
    modelContainer.on("change", func)

  inflate: (element) ->
    nodes = $("<div>#{element}</div>")
    @applySnippets nodes
    return nodes.contents()

  applySnippets: (nodes, parentsAttributes = {}) =>

    applySnippetsToSingleNodeAndChildren = @applySnippetsToSingleNodeAndChildren

    nodes.each ->
      applySnippetsToSingleNodeAndChildren $(@), parentsAttributes

  applySnippetsToSingleNodeAndChildren: (node, parentsAttributes) =>

    parentsAndNodesAttributes = @combine(parentsAttributes, node.data())
    snippetName = node.data('snippet')

    if snippetName?
      snippetFunc = @snippets[snippetName]
      throw "Unable to find snippet '#{snippetName}'" unless snippetFunc?

      node.data("snippet", null)
      node.attr("data-snippet", null) # Otherwise this will be recursively invoked

      nodeAfterSnippetApplied = snippetFunc.call(this, node, parentsAndNodesAttributes)

      if nodeAfterSnippetApplied == null
        node.detach()
      else
        if node != nodeAfterSnippetApplied
          node.replaceWith nodeAfterSnippetApplied
        #Snippets were applied therefore we should try applying again
        @applySnippets nodeAfterSnippetApplied, parentsAndNodesAttributes

    else
      @applySnippets node.contents(), parentsAndNodesAttributes

  combine: (parentAttrs, childAttrs) =>

    combinedAttributes = new Object extends childAttrs
    combinedAttributes[key] = parentAttrs[key] for key of parentAttrs
    return combinedAttributes
