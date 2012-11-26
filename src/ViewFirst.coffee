class window.ViewFirst

  constructor: (@views = {}) ->
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
  
     if(ViewFirst.isNodeListOrArray(nodeOrNodeList))
  
       nodeArray = ViewFirst._convertToFlatArray(nodeOrNodeList)
     
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

  #Need to cope with nested arrays
  @_convertToFlatArray: (nodeList) =>
    nodeArray = []
    ViewFirst._addAllToArray(nodeList, nodeArray)
    return nodeArray
    
  @_addAllToArray: (nodeList, nodeArray) =>
    ((node) -> if ViewFirst.isNodeListOrArray(node) then ViewFirst._addAllToArray(node, nodeArray) else nodeArray.push(node) ) node for node in nodeList
    
       
  @isNodeListOrArray: (nodeOrNodeList) => return nodeOrNodeList.toString() is '[object NodeList]' || nodeOrNodeList instanceof Array

  
  @containsChild: (parent, child) =>
  
    contained = !child?
    ((node) => contained = contained || node == child) node for node in parent.childNodes
    contained
  