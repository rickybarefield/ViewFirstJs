class window.View

  @TEXT_NODE = 3

  constructor: (@viewFirst, @viewId, @element) ->

  render: ->
    wrapped = document.createElement("div")
    wrapped.innerHTML = "<div id=\"boom\">#{@element}</div>"
    @applySnippetsRecursively(wrapped, wrapped.firstChild)
    return wrapped.firstChild.childNodes


  applySnippetsRecursively: (parent, domNode, attributes = {a: "b"}) ->
    unless domNode?.nodeType is View.TEXT_NODE
      @applySnippetsRecursivelyToNonTextNode(parent, domNode, attributes)
    else
      domNode
    

  applySnippetsRecursivelyToChildNodes: (parent, childNodes, attributes) ->

    combinedAttributes = new Object extends attributes
    parentsData = $(parent).data()
    combinedAttributes[key]=parentsData[key] for key of parentsData

    if childNodes?
        for node in childNodes
          do (node) =>
            @applySnippetsRecursively(parent, node, combinedAttributes)
  
  
  applySnippetsRecursivelyToNonTextNode: (parent, domNode, attributes) ->
  
    withSnippetsApplied = @applySnippets(domNode, attributes)
    
    if withSnippetsApplied? and domNode != withSnippetsApplied
      withSnippetsApplied = ViewFirst.replaceNode(parent, domNode, withSnippetsApplied)

      if ViewFirst.isNodeListOrArray(withSnippetsApplied)
        @applySnippetsRecursivelyToChildNodes(parent, withSnippetsApplied, attributes)
      else
        @applySnippetsRecursively(parent, withSnippetsApplied, attributes)

    else
      @applySnippetsRecursivelyToChildNodes(domNode, domNode?.childNodes, attributes)
      

  applySnippets: (element, attributes) =>
  
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
