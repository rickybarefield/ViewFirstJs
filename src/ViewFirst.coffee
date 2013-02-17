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

  uniqueNumber = -> if @lastNumber? then @lastNumber++ else @lastNumber = 1

  bindCollection: (collection, parentNode, func) ->

    boundModels = {}

    addChild = (modelToAdd) =>
      console.log "adding child"
      childNode = func(modelToAdd)
      @bindTextNodes(childNode, modelToAdd)
      @bindNodeValues(childNode, modelToAdd)
      $parent.append(childNode)
      boundModels[modelToAdd.get("id")] = childNode

    removeChild = (modelToRemove) ->
      childNode = boundModels[modelToRemove.get("id")]
      $(childNode).detach()
      delete boundModels[modelToRemove.get("id")]

    $parent = $(parentNode)

    context = uniqueNumber()
    console.log("context = #{context}")

    collection.each (model) -> addChild(model)

    collection.on "add", ((newModel) -> addChild(newModel)), context
    collection.on "remove", ((removedModel) -> removeChild(removedModel)), context
    collection.on "reset", ( =>
      collection.off null, null, context
      @bindCollection(collection, parentNode, func)), context

  bindNodeToModel: (node, model, func) ->
    currentBinding = node["currentBinding"]
    if currentBinding?
      #TODO There is a slight problem here
      #Unbinding leaves an unbinder bound! See bind in model, an unbinder is added which
      #can't easily be removed, may have to override bind
      model.off "change", currentBinding
    node["currentBinding"] = model.on "change", func

  bindTextNodes: (node, model) ->

    BindHelpers.doForNodeAndChildren node, (node) =>

      getReplacementText = (nodeText, model) ->
        removeSurround = (str) ->
          str.match /[^#{}]+/
        nodeText.replace /#\{[^\}]*\}/g, (match) -> model.get(removeSurround(match))

      originalText = node.text()

      doReplacement = ->
        replacementText = getReplacementText(originalText, model)
        node.get(0).nodeValue = replacementText

      if node.get(0).nodeType is ViewFirst.TEXT_NODE and node.text().match /#{.*}/
        @bindNodeToModel(node, model, doReplacement)
        doReplacement()


  addNamedBinding: (name, event, $node, func) ->
    key = event + "." + name
    $node.unbind key
    $node.bind key, func


  bindNodeValues: (node, model) ->

    BindHelpers.doForNodeAndChildren node, (aNode) =>
      property = aNode.attr("data-property")
      if property?
        @bindNodeToModel aNode, model, =>
          aNode.val(model.get(property))

        @addNamedBinding "updateModel", "blur", aNode, =>
          model.set(property, aNode.val())
          model.save()

        aNode.val(model.get(property))


  @doForNodeAndChildren: (node, func) ->

    func(node)
    for childNode in node.contents()
      BindHelpers.doForNodeAndChildren $(childNode), func

class ViewFirst extends BindHelpers

  @TEXT_NODE = 3

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