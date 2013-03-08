class ViewFirstModel extends Backbone.Model

  @instances: {}
  
  constructor: (attributes) ->

    instances = this.constructor.instances

    if attributes?.id?
      if instances[attributes.id]?
        console.log "returning an existing instance"
        model = instances[attributes.id]
        Backbone.Model.apply(model, arguments)
        return model

      instances[attributes.id] = this

    Backbone.Model.apply(this, arguments)

class TemplatingSnippets

  @add: (viewFirst) ->
    viewFirst.addSnippet "surround", @surroundSnippet
    viewFirst.addSnippet "embed", @embedSnippet


  @surroundSnippet: (viewFirst, node, argumentMap) =>

    nodes = node.contents() #This snippet is only interested in child nodes
    console.log "_surroundSnippet invoked with #{node}"

    surroundingName = argumentMap['with']
    at = argumentMap['at']
    surroundingView = viewFirst.findView(surroundingName)

    unless surroundingView?
      throw "Unable to find surrounding template '#{surroundingName}'"

    surroundingContent = $(surroundingView.getElement())

    if at?
      @bind(surroundingContent, nodes, at)
    else
      @bindParts(surroundingContent, nodes)

    return surroundingContent

  @bindParts: (surroundingContent, nodes) ->

    for child in nodes
      at = $(child).attr("data-at")
      @bind(surroundingContent, child.childNodes, at) if at?

  @bind: (surroundingContent, html, at) ->
    bindElement = surroundingContent.find("[data-bind-name='#{at}']")
    bindElement.replaceWith(html)


  @embedSnippet: (viewFirst, html, argumentMap) ->

    templateName = argumentMap['template']
    embeddedView = viewFirst.findView(templateName)

    unless embeddedView?
      throw "Unable to find template to embed '#{templateName}'"

    return $(embeddedView.getElement()).clone()

class BindHelpers

  constructor: () ->

  uniqueNumber = => 
    if @lastNumber? then @lastNumber++ else @lastNumber = 1
    return @lastNumber

  bindCollection: (collection, parentNode, func) ->

    boundModels = {}

    addChild = (modelToAdd) =>
      console.log "adding child"
      childNode = func(modelToAdd)
      if childNode?
        @bindNodes(childNode, modelToAdd)
        @bindNodeValues(childNode, modelToAdd)
        $parent.append(childNode)
        boundModels[modelToAdd["cid"]] = childNode

    removeChild = (modelToRemove) ->
      childNode = boundModels[modelToRemove["cid"]]
      $(childNode).detach()
      delete boundModels[modelToRemove["cid"]]

    $parent = $(parentNode)

    context = uniqueNumber()
    console.log("context = #{context}")

    collection.each (model) -> addChild(model)

    collection.on "add", ((newModel) -> addChild(newModel)), context
    collection.on "remove", ((removedModel) -> removeChild(removedModel)), context
    collection.on "reset", ( =>
      collection.off null, null, context
      @bindCollection(collection, parentNode, func)), context

  bindNodeToResultOfFunction: (node, func) ->

    previouslyBoundModels = node.get(0)["previouslyBoundModels"]
    previouslyBoundFunction = node.get(0)["previouslyBoundFunction"]

    affectingModels = func()

    (previouslyBoundModel.off("change", currentlyBoundFunction) for previouslyBoundModel in previouslyBoundModels) if  previouslyBoundModels?
    affectingModel.on("change", func) for affectingModel in affectingModels

    node.get(0)["previouslyBoundModels"] = affectingModels
    node.get(0)["previouslyBoundFunction"] = func
	
  bindNodes: (node, model) ->

    BindHelpers.doForNodeAndChildren node, (node) =>

      getReplacementTextAndAffecingModels = (nodeText, model) ->
        removeSurround = (str) ->
          str.match(/[^#{}]+/)[0]
        affectingModels = []
        replacementText = nodeText.replace /#\{[^\}]*\}/g, (match) ->
          key = removeSurround(match)
          elements = key.split(".")
          currentModel = model
          for element in elements
            oldModel = currentModel
            currentModel = currentModel?.get(element)
          affectingModels.push oldModel
          return currentModel
        return [replacementText, affectingModels]

      originalText = node.get(0).nodeValue

      doReplacement = ->
        [replacementText, affectingModels] = getReplacementTextAndAffecingModels(originalText, model)
        node.get(0).nodeValue = replacementText
        return affectingModels

      if (node.get(0).nodeType is ViewFirst.TEXT_NODE or node.get(0).nodeType is ViewFirst.ATTR_NODE) and originalText.match /#{.*}/
        @bindNodeToResultOfFunction(node, doReplacement)

  bindNodeValues: (node, model) ->

    BindHelpers.doForNodeAndChildren node, (aNode) =>
      property = aNode.attr("data-property")
      if property?
        @bindNodeToResultOfFunction aNode, =>
          aNode.val(model.get(property))
          return model

        aNode.off("blur.viewFirst")
        aNode.on("blur.viewFirst", =>
          model.set(property, aNode.val())
          model.save() unless model.isNew())

        aNode.val(model.get(property))

  @doForNodeAndChildren: (node, func) ->

	#Apply to node
    func(node)

	#Apply to attributes    
    attributes = node.get(0).attributes
    if attributes?
      func($(attribute)) for attribute in attributes
    
    #Apply to children
    for childNode in node.contents()
      BindHelpers.doForNodeAndChildren $(childNode), func

class ViewFirst extends BindHelpers

  @TEXT_NODE = 3
  @ATTR_NODE = 2

  ###
    namedModelEventListeners contain a map of namedModel name to array of event handlers
  ###
  constructor: (@indexView,
    @views = {}, 
    @namedModels={}, 
    @namedModelEventListeners={}, 
    @router = new ViewFirstRouter(this),
    @snippets = {}) ->
    
    TemplatingSnippets.add(this)


  initialize: ->

    $('script[type="text/view-first-template"]').each (id, el) =>
      node = $(el)
      console.log "Loading script with id=#{node.attr 'name' }"
      viewName = node.attr("name")
      @createView viewName , node.html()
      @router.addRoute viewName, viewName == @indexView

    Backbone.history.start()


  findView: (viewId) ->
    @views[viewId]


  renderView: (viewId) ->

    @currentView = viewId
    view = @findView viewId
    rendered = view.render()
    $('body').html rendered

  navigate: (viewId) ->
    Backbone.history.navigate viewId, true

  createView: (viewId, content) ->

    view = new View(this, viewId, content)
    @views[viewId] = view
    return view


  addSnippet: (name, func) ->
    @snippets[name] = func


  setNamedModel: (name, model, dontSerialize = false) ->

    oldModel = @namedModels[name]

    if model?
      @namedModels[name] = model
      model.constructor.bind("destroy", => @setNamedModel(name, null))
    else
      delete @namedModels[name]

    console.log "named model set"

    @router.updateState() unless dontSerialize

    eventListenerArray = @namedModelEventListeners[name]

    if eventListenerArray?
      func(oldModel, model) for func in eventListenerArray

  addNamedModelEventListener: (name, func) ->

    eventListenerArray = @namedModelEventListeners[name]

    unless eventListenerArray?
      eventListenerArray = []
      @namedModelEventListeners[name] = eventListenerArray

    eventListenerArray.push(func)

window.ViewFirst = ViewFirst
window.ViewFirstModel = ViewFirstModel