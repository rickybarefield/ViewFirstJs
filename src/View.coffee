class window.View

  @TEXT_NODE = 3

  constructor: (@viewFirst, @viewId, @element) ->

  render: ->
    wrapped = document.createElement("div")
    wrapped.innerHTML = "<div>#{@element}</div>"
    @applySnippetsRecursively(wrapped, wrapped.firstChild)
    return wrapped.firstChild


  applySnippetsRecursively: (parent, domNode) ->
    unless domNode.nodeType is View.TEXT_NODE
      @applySnippetsRecursivelyToNonTextNode(parent, domNode)
    else
      domNode
    

  applySnippetsRecursivelyToChildNodes: (parent, childNodes) ->
    for node in childNodes
      do (node) =>
        @applySnippetsRecursively(parent, node)
  
  
  applySnippetsRecursivelyToNonTextNode: (parent, domNode) ->
  
    withSnippetsApplied = @applySnippets(domNode)
    
    if withSnippetsApplied? and domNode != withSnippetsApplied
      withSnippetsApplied = ViewFirst.replaceNode(parent, domNode, withSnippetsApplied)

      if ViewFirst.isNodeListOrArray(withSnippetsApplied)
        @applySnippetsRecursivelyToChildNodes(parent, withSnippetsApplied)
      else
        @applySnippetsRecursively(parent, withSnippetsApplied)

    else
      @applySnippetsRecursivelyToChildNodes(domNode, domNode.childNodes)
      

  applySnippets: (element) =>
  
    node = $(element)
    snippetName = node.attr('data-snippet')
  
    return if snippetName?
      console.log "snippet usage found for #{snippetName}"
      snippetFunc = @viewFirst.snippets[snippetName]
      throw "Unable to find snippet '#{snippetName}'" unless snippetFunc?

      node.removeAttr("data-snippet") # Otherwise this will be recursively invoked
      snippetFunc @viewFirst, element, node.data()
    else
      element
      
      
  getElement: () => @element
