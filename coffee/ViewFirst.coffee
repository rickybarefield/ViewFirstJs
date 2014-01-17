ViewFirstModel = require("./ViewFirstModel")
ViewFirstRouter = require("./ViewFirstRouter")
ModelContainer = require("./ViewFirstModelContainer")
BindHelpers = require("./BindHelpers")
TemplatingSnippets = require("./TemplatingSnippets")
OneToMany = require("./OneToMany")
ManyToOne = require("./ManyToOne")
ViewFirstConverters = require("./ViewFirstConverters")
Sync = require("./ScrudSync")
$ = require("./jquery-dep")
_ = require("./underscore-dep")

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

    for AModel in Models

      do (AModel) =>

        constructor = ->

        constructor = ->
          this.constructor = constructor
          AModel.apply(this, arguments)
          return this

        _.extend(constructor, AModel)

        constructor.prototype = AModel.prototype

        constructor.instances = []
        constructor.sync = sync
        constructor.instancesById = {}

        @[AModel.modelName] = constructor

    @views = {}
    @namedModels = {}
    @snippets = {}
    @router = new ViewFirstRouter(this)
    @addSnippet(key, value) for key, value of TemplatingSnippets
    ViewFirstConverters(@)

  addViews = ->

    $('script[type="text/view-first-template"]').each (id, el) =>
      node = $(el)
      viewName = node.attr("name")
      @views[viewName] = node.html()
      #TODO @router.addRoute viewName, viewName == @indexView


  initialize: (callback) =>

    #TODO Router needs initialising but current plan is to have no initial view
    #@router.initialize()
    @sync.connect(callback)
    addViews.call(@)

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
