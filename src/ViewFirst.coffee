class window.ViewFirst

  ###
    
    namedModelEventListeners contain a map of namedModel name to array of event handlers
  
  ###
  constructor: (@views = {}, @namedModels={}, @namedModelEventListeners={}) ->
    @snippets =
      surround: ViewFirst._surroundSnippet
      embed: ViewFirst._embedSnippet
    @addViews()
  
  findView: (viewId) => this.views[viewId] 

  renderView: (viewId) =>
    view = @findView(viewId)
    $('body').html(view.render())
  
  addViews: =>
    $('script[type="text/view-first-template"]').each( (id, el) => 
                                                          node = $(el)
                                                          console.log "Loading script with id=#{node.attr('name')}"
                                                          @createView(node.attr("name"), node.html())) 
  createView: (viewId, content) =>

    view = new View(this, viewId, content)
    this.views[viewId] = view
    return view

  addSnippet: (name, func) =>
    
    @snippets[name] = func

  @_surroundSnippet: (viewFirst, nodes, argumentMap)  =>

    console.log("_surroundSnippet invoked with #{nodes}")
  
    surroundingName = argumentMap['with']
    at = argumentMap['at']
    surroundingView = viewFirst.findView(surroundingName)

    if(!surroundingView?)
      throw "Unable to find surrounding template '#{surroundingName}'"
    
    surroundingContent = document.createElement("div")
    surroundingContent.innerHTML = surroundingView.getElement()
    
    if at?
      @_bind(surroundingContent, nodes, at)
    else
      @_bindParts(surroundingContent, nodes)
    
    return surroundingContent.childNodes

  @_bindParts: (surroundingContent, nodes) =>

    child = nodes[0]
    while child?
      at = $(child).attr("data-at")
      if(at?)
        @_bind(surroundingContent, child.childNodes, at)
      child = child.nextSibling
  
  @_bind: (surroundingContent, html, at) =>
    bindElement = $(surroundingContent).find("[data-bind-name='#{at}']")
    bindElement.replaceWith(html)
    
  @_embedSnippet: (viewFirst, html, argumentMap) =>
  
    templateName = argumentMap['template']
    embeddedView = viewFirst.findView(templateName)
    
    if(!embeddedView?)
      throw "Unable to find template to embed '#{templateName}'"
    
    tmp = document.createElement("div")
    tmp.innerHTML = embeddedView.render()
    
    return tmp.childNodes
    
  @replaceNode: (parent, nodeToReplace, nodeOrNodeList) =>

    #Need to cope with nested arrays
    convertToFlatArray = (nodeList) =>
      addAllToArray = (nodeList, nodeArray) =>
        ((node) -> if ViewFirst.isNodeListOrArray(node) then addAllToArray(node, nodeArray) else nodeArray.push(node) ) node for node in nodeList

      nodeArray = []
      addAllToArray(nodeList, nodeArray)
      return nodeArray
  
    if(ViewFirst.isNodeListOrArray(nodeOrNodeList))
  
      nodeArray = convertToFlatArray(nodeOrNodeList)
     
      nextSibling = nodeToReplace.nextSibling
      ((newNode) ->
        if(!ViewFirst.containsChild(parent, nextSibling))
           throw "nextSibling was not contained in parent"
        parent.insertBefore(newNode, nextSibling)) newNode for newNode in nodeArray
      parent.removeChild(nodeToReplace)
      return nodeArray
    else
      parent.replaceChild(nodeOrNodeList, nodeToReplace)
      return nodeOrNodeList

       
  @isNodeListOrArray: (nodeOrNodeList) => return nodeOrNodeList.toString() is '[object NodeList]' || nodeOrNodeList instanceof Array

  
  @containsChild: (parent, child) =>
    contained = !child?
    ((node) => contained = contained || node == child) node for node in parent.childNodes
    contained

  setNamedModel: (name, model) =>

    oldModel = @namedModels[name]
    @namedModels[name] = model
    
    eventListenerArray = @namedModelEventListeners[name]
    
    if eventListenerArray?
      func(oldModel, model) for func in eventListenerArray

  getOrCreateNamedModel: (name, modelClass) =>
  
    namedModel = @namedModels[name]
    
    if !namedModel?
      namedModel = new modelClass()
      @namedModels[name] = namedModel
    
    return namedModel

  addNamedModelEventListener: (name, func) =>
  
    eventListenerArray = @namedModelEventListeners[name]

    if !eventListenerArray?
      eventListenerArray = []
      @namedModelEventListeners[name] = eventListenerArray
    
    eventListenerArray.push(func)
  