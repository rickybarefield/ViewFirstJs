class window.ViewFirst

  @TEXT_NODE = 3

  ###

    namedModelEventListeners contain a map of namedModel name to array of event handlers

  ###
  constructor: (@indexView, @views = {}, @namedModels={}, @namedModelEventListeners={}, @namedBindings = {}, @router=new Router(this)) ->
    @snippets =
      surround: ViewFirst._surroundSnippet
      embed: ViewFirst._embedSnippet


  initialize: ->

    $('script[type="text/view-first-template"]').each (id, el) =>
      node = $(el)
      console.log "Loading script with id=#{node.attr 'name' }"
      @createView node.attr("name"), node.html()

    @router.deserialize()
    unless @currentView?
      @renderView @indexView
      @router.serialize()


  findView: (viewId) ->
      @views[viewId]


  renderView: (viewId) ->

    @currentView = viewId
    view = @findView viewId
    $('body').html view.render()


  createView: (viewId, content) ->

    view = new View(this, viewId, content)
    @views[viewId] = view
    return view


  addSnippet: (name, func) ->
      @snippets[name] = func


  setNamedModel: (name, model, serialize = true) ->

    oldModel = @namedModels[name]

    if model?
      @namedModels[name] = model
      model.constructor.bind("destroy", => @setNamedModel(name, null))
    else
      delete @namedModels[name]

    if serialize
      @router.serialize()

    eventListenerArray = @namedModelEventListeners[name]

    if eventListenerArray?
      func(oldModel, model) for func in eventListenerArray


  getOrCreateNamedModel: (name, modelClass) ->

    namedModel = @namedModels[name]

    unless namedModel?
      namedModel = new modelClass()
      @namedModels[name] = namedModel

    return namedModel


  addNamedModelEventListener: (name, func) ->

    eventListenerArray = @namedModelEventListeners[name]

    unless eventListenerArray?
      eventListenerArray = []
      @namedModelEventListeners[name] = eventListenerArray

    eventListenerArray.push(func)


  @_surroundSnippet: (viewFirst, node, argumentMap) =>

    nodes = node.children #This snippet is only interested in child nodes
    console.log "_surroundSnippet invoked with #{node}"

    surroundingName = argumentMap['with']
    at = argumentMap['at']
    surroundingView = viewFirst.findView(surroundingName)

    unless surroundingView?
      throw "Unable to find surrounding template '#{surroundingName}'"

    surroundingContent = document.createElement("div")
    surroundingContent.innerHTML = surroundingView.getElement()

    if at?
      @_bind(surroundingContent, nodes, at)
    else
      @_bindParts(surroundingContent, nodes)

    return surroundingContent.childNodes


  @_bindParts: (surroundingContent, nodes) ->

    child = nodes[0]
    while child?

      at = $(child).attr("data-at")
      @_bind(surroundingContent, child.childNodes, at) if at?

      child = child.nextSibling


  @_bind: (surroundingContent, html, at) ->
    bindElement = $(surroundingContent).find("[data-bind-name='#{at}']")
    bindElement.replaceWith(html)


  @_embedSnippet: (viewFirst, html, argumentMap) ->

    templateName = argumentMap['template']
    embeddedView = viewFirst.findView(templateName)

    unless embeddedView?
      throw "Unable to find template to embed '#{templateName}'"

    tmp = document.createElement("div")
    tmp.innerHTML = embeddedView.render()

    return tmp.childNodes


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


  @isNodeListOrArray: (nodeOrNodeList) ->
      return nodeOrNodeList.toString() is '[object NodeList]' or nodeOrNodeList instanceof Array


  @containsChild: (parent, child) ->
    contained = !child?
    for node in parent.childNodes
      do (node) ->
        contained = contained || node is child
    contained


  bindModel: (modelClass, parentNode, func) ->

    boundModels = {}

    addChild = (modelToAdd) =>
      childNode = func(modelToAdd)
      @bindTextNodes(childNode, modelToAdd)
      @bindNodeValues(childNode, modelToAdd)
      $parent.append(childNode)
      boundModels[modelToAdd] = childNode

    removeChild = (modelToRemove) ->
      childNode = boundModels[modelToRemove]
      $(childNode).detach()
      delete boundModels[modelToRemove]

    $parent = $(parentNode)

    addChild(model) for model in modelClass.all()

    modelClass.bind "create", (newModel) -> addChild(newModel)
    modelClass.bind "destroy", (removedModel) -> removeChild(removedModel)


  bindNodeToModel: (node, model, func) ->
    currentBinding = node["currentBinding"]
    if currentBinding?
      #TODO There is a slight problem here
      #Unbinding leaves an unbinder bound! See bind in model, an unbinder is added which
      #can't easily be removed, may have to override bind
      model.constructor.unbind "save", currentBinding
    node["currentBinding"] = model.bind "save", func


  bindTextNodes: (node, model) ->

    ViewFirst.doForNodeAndChildren node, (node) =>

      getReplacementText = (nodeText, model) ->
        removeSurround = (str) ->
          str.match /[^#{}]+/
        nodeText.replace /#\{[^\}]*\}/g, (match) -> model[removeSurround(match)]

      originalText = node.nodeValue

      doReplacement = ->
        replacementText = getReplacementText(originalText, model)
        node.nodeValue = replacementText

      if node.nodeType is ViewFirst.TEXT_NODE and node.nodeValue.match /#{.*}/
        @bindNodeToModel(node, model, doReplacement)
        doReplacement()


  addNamedBinding: (name, event, $node, func) ->
    key = event + "." + name
    $node.unbind key
    $node.bind key, func


  bindNodeValues: (node, model) ->

    ViewFirst.doForNodeAndChildren node, (singleNode) =>
      jQNode = $(singleNode)
      property = jQNode.attr("data-property")
      if property?
        @bindNodeToModel singleNode, model, =>
          jQNode.val(model[property])

        @addNamedBinding "updateModel", "blur", jQNode, =>
          model[property] = jQNode.val()
          model.save()

        jQNode.val(model[property])


  @doForNodeAndChildren: (node, func) ->

    func(node)
    child = node.firstChild
    while child?
      @doForNodeAndChildren(child, func)
      child = child.nextSibling
