class window.View
  
  @TEXT_NODE = 3
  
  constructor: (@viewFirst, @viewId, @element) ->
  
  render: ->
    nodes = $("<div>#{@element}</div>")
    @applySnippets nodes
    return nodes.contents()
    
  applySnippets: (nodes, parentsAttributes = {}) =>
  
    applySnippetsToSingleNodeAndChildren = @applySnippetsToSingleNodeAndChildren
    
    nodes.each ->
      applySnippetsToSingleNodeAndChildren $(@), parentsAttributes
  
  applySnippetsToSingleNodeAndChildren: (node, parentsAttributes) =>
  
    parentsAndNodesAttributes = @combine(parentsAttributes, node.data())
    snippetName = node.attr('data-snippet')
    
    if snippetName?
      console.log "snippet usage found for #{snippetName}"
      snippetFunc = @viewFirst.snippets[snippetName]
      throw "Unable to find snippet '#{snippetName}'" unless snippetFunc?
      
      node.removeAttr("data-snippet") # Otherwise this will be recursively invoked
	    
      nodeAfterSnippetApplied = snippetFunc(@viewFirst, node, parentsAndNodesAttributes)
      
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
    
  getElement: () => @element
