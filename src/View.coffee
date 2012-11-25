class window.View

  @TEXT_NODE = 3

  constructor: (@viewFirst, @viewId, @element) ->

  render: ->
    wrapped = document.createElement("div")
    wrapped.innerHTML = "<div>#{@element}</div>"
    @applySnippetsRecursively(wrapped, wrapped.firstChild)
    return wrapped.firstChild.innerHTML

  applySnippetsRecursively: (parent, node) => 
    
    if node.nodeType != View.TEXT_NODE then @applySnippetsRecursivelyToNonTextNode(parent, node) else node
    
  
  applySnippetsRecursivelyToNonTextNode: (parent, node) =>
  
    replaced = @applySnippetsAndReplace(parent, node)
    
    child = replaced.firstChild
    while child?
      childReplacement = @applySnippetsRecursively(replaced, child)
      child = childReplacement.nextSibling
    
    return replaced
    
  applySnippetsAndReplace: (parent, node) =>

    console.log "applySnippetsAndReplace(#{parent},#{node})"

    placeHolder = document.createElement("p")
    parent.replaceChild(placeHolder, node)

    nodeAsString = @nodeAsString node
    
    withSnippetsApplied = @applySnippets nodeAsString

    tmp = document.createElement("div")
    tmp.innerHTML = withSnippetsApplied
    
    firstReplacement = tmp.firstChild
    
    if @applyingSnippetsHadAnEffect(withSnippetsApplied, nodeAsString)
      child = tmp.firstChild
      while child?
        appliedChild = @applySnippetsAndReplace(tmp, child)
        child = appliedChild.nextSibling
      firstReplacement = tmp.firstChild
    
    @replaceNodeWithChildrenOfOther(parent, placeHolder, tmp)

    return firstReplacement
     
  applySnippets: (element) =>
  
    node = $(element)
    snippetName = node.attr('data-snippet')

    console.log("snippetName=#{snippetName}")
  
    return if snippetName?
      snippetFunc = @viewFirst.snippets[snippetName]
      if(!snippetFunc?)
        throw "Unable to find snippet '#{snippetName}'"
      snippetFunc(@viewFirst, node.html(), node.data())
    else
      element

  applyingSnippetsHadAnEffect: (withSnippetsApplied, nodeAsString) -> withSnippetsApplied != nodeAsString

  replaceNodeWithChildrenOfOther: (parent, node, other) =>
  
    replacement = other.firstChild
    parent.replaceChild(replacement, node)
    while other.firstChild? 
      nextReplacement = other.firstChild
      parent.insertBefore(nextReplacement, replacement.nextSibling)
      replacement = nextReplacement
      
  nodeAsString: (node) =>
  
    tmp = document.createElement("div")
    tmp.appendChild(node)
    return tmp.innerHTML
  
      
  getElement: () => @element
