class window.View

  @TEXT_NODE = 3

  constructor: (@viewFirst, @viewId, @element) ->

  render: ->
    nodes = $(@element)
    applySnippetsCaptured = @applySnippets
    for element in nodes
      node = $(element)
      applySnippetsCaptured(node, node.data())

  applySnippets: (node, attributes) =>
  
    snippetName = node.attr('data-snippet')
  
    if snippetName?
      console.log "snippet usage found for #{snippetName}"
      snippetFunc = @viewFirst.snippets[snippetName]
      throw "Unable to find snippet '#{snippetName}'" unless snippetFunc?

      node.removeAttr("data-snippet") # Otherwise this will be recursively invoked
      nodeAfterSnippetApplied = snippetFunc(@viewFirst, node, attributes)
      if nodeAfterSnippetApplied == null
        node.detach()
      else
        if node != nodeAfterSnippetApplied
          node.replaceWith nodeAfterSnippetApplied
        node = @applySnippetsToNodesCombiningAttributes(nodeAfterSnippetApplied, attributes)
    else
      @applySnippetsToChildNodes(node, attributes)

    return node

  applySnippetsToChildNodes: (node, attributes) =>

    childNodes = node.contents()
    @applySnippetsToNodesCombiningAttributes(childNodes, attributes)
    return node

  applySnippetsToNodesCombiningAttributes: (nodes, attributesFromParent) =>

    applySnippetsCaptured = @applySnippets
    for element in nodes
      childNode = $(element)
      combinedAttributes = new Object extends childNode.data()
      combinedAttributes[key]=attributesFromParent[key] for key of attributesFromParent
      applySnippetsCaptured(childNode, combinedAttributes)
    return nodes

      
  getElement: () => @element
