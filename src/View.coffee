class window.View

  @TEXT_NODE = 3

  constructor: (@viewFirst, @viewId, @element) ->

  render: ->
    wrapped = document.createElement("div")
    wrapped.innerHTML = "<div>#{@element}</div>"
    @applySnippetsRecursively(wrapped, wrapped.firstChild)
    return wrapped.firstChild

  applySnippetsRecursively: (parent, domNode) => 
    
    if domNode.nodeType != View.TEXT_NODE then s@applySnippetsRecursivelyToNonTextNode(parent, domNode) else domNode
    
  applySnippetsRecursivelyToChildNodes: (parent, childNodes) =>
  
    nodeArray = []
    ((node) -> (nodeArray.push(node))) node for node in childNodes
    ((node) => @applySnippetsRecursively(parent, node)) node for node in nodeArray
  
  applySnippetsRecursivelyToNonTextNode: (parent, domNode) =>
  
    withSnippetsApplied = @applySnippets(domNode)

    if(domNode != withSnippetsApplied)
      withSnippetsApplied = ViewFirst.replaceNode(parent, domNode, withSnippetsApplied)
      if(ViewFirst.isNodeListOrArray(withSnippetsApplied))
        @applySnippetsRecursivelyToChildNodes(parent, withSnippetsApplied)
      else
        @applySnippetsRecursively(parent, withSnippetsApplied)
    else
      @applySnippetsRecursivelyToChildNodes(domNode, domNode.childNodes)
      
  applySnippets: (element) =>
  
    node = $(element)
    snippetName = node.attr('data-snippet')
  
    return if snippetName?
      console.log("snippet usage found for #{snippetName}")
      snippetFunc = @viewFirst.snippets[snippetName]
      if(!snippetFunc?)
        throw "Unable to find snippet '#{snippetName}'"
      node.removeAttr("data-snippet") #Otherwise this will be recursively invoked
      snippetFunc(@viewFirst, element, node.data())
    else
      element
      
      
  getElement: () => @element
