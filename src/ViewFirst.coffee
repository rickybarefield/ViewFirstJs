class window.ViewFirstModel extends Backbone.Model

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

class window.ViewFirst

  @TEXT_NODE = 3

  ###

    namedModelEventListeners contain a map of namedModel name to array of event handlers

  ###
  constructor: (@indexView, @views = {}, @namedModels={}, @namedModelEventListeners={}, @namedBindings = {}, @router=new ViewFirstRouter(this)) ->
    @snippets =
      surround: ViewFirst._surroundSnippet
      embed: ViewFirst._embedSnippet

  uniqueNumber = -> if @lastNumber? then @lastNumber++ else @lastNumber = 0


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


  @_surroundSnippet: (viewFirst, node, argumentMap) =>

    nodes = node.contents() #This snippet is only interested in child nodes
    console.log "_surroundSnippet invoked with #{node}"

    surroundingName = argumentMap['with']
    at = argumentMap['at']
    surroundingView = viewFirst.findView(surroundingName)

    unless surroundingView?
      throw "Unable to find surrounding template '#{surroundingName}'"

    surroundingContent = $(surroundingView.getElement())

    if at?
      @_bind(surroundingContent, nodes, at)
    else
      @_bindParts(surroundingContent, nodes)

    return surroundingContent

  @_bindParts: (surroundingContent, nodes) ->

    for child in nodes
      at = $(child).attr("data-at")
      @_bind(surroundingContent, child.childNodes, at) if at?

  @_bind: (surroundingContent, html, at) ->
    bindElement = surroundingContent.find("[data-bind-name='#{at}']")
    bindElement.replaceWith(html)


  @_embedSnippet: (viewFirst, html, argumentMap) ->

    templateName = argumentMap['template']
    embeddedView = viewFirst.findView(templateName)

    unless embeddedView?
      throw "Unable to find template to embed '#{templateName}'"

    return $(embeddedView.getElement()).clone()

  ###
  @replaceNode: (parent, nodeToReplace, nodeOrNodeList) ->

    #Need to cope with nested arrays
    convertToFlatArray = (nodeList) =>
      addAllToArray = (nodeList, nodeArray) =>
        for node in nodeList
          do (node) =>
              if @isNodeListOrArray(node) then addAllToArray(node, nodeArray) else nodeArray.push(node)

      nodeArray = []
      addAllToArray(nodeList, nodeArray)
      return nodeArray

    if @isNodeListOrArray nodeOrNodeList
      nodeArray = convertToFlatArray nodeOrNodeList
      nextSibling = nodeToReplace.nextSibling

      for newNode in nodeArray
        do (newNode) =>
          unless @containsChild(parent, nextSibling)
            throw "nextSibling was not contained in parent"
          parent.insertBefore(newNode, nextSibling)

      parent.removeChild(nodeToReplace)
      return nodeArray
    else
      parent.replaceChild(nodeOrNodeList, nodeToReplace)
      return nodeOrNodeList
    ###

  @isNodeListOrArray: (nodeOrNodeList) ->
      return nodeOrNodeList.toString() is '[object NodeList]' or nodeOrNodeList instanceof Array


  @containsChild: (parent, child) ->
    contained = !child?
    for node in parent.childNodes
      do (node) ->
        contained = contained || node is child
    contained


  bindCollection: (collection, parentNode, func) ->

    boundModels = {}

    addChild = (modelToAdd) =>
      console.log "adding child"
      childNode = func(modelToAdd)
      @bindTextNodes(childNode, modelToAdd)
      @bindNodeValues(childNode, modelToAdd)
      $parent.append(childNode)
      boundModels[modelToAdd] = childNode

    removeChild = (modelToRemove) ->
      childNode =boundModels[modelToRemove]
      $(childNode).detach()
      delete boundModels[modelToRemove]

    $parent = $(parentNode)

    context = uniqueNumber()
    console.log("context = #{context}")

    collection.each (model) -> addChild(model)

    collection.on "add", ((newModel) -> addChild(newModel)), context
    collection.on "destroy", ((removedModel) -> removeChild(removedModel)), context
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

    ViewFirst.doForNodeAndChildren node, (node) =>

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

    ViewFirst.doForNodeAndChildren node, (aNode) =>
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
      ViewFirst.doForNodeAndChildren $(childNode), func

