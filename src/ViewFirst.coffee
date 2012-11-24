class ViewFirst

  constructor: (@views = {}) ->
    @snippets =
      surround: ViewFirst._surroundSnippet

  findView: (viewId) => this.views[viewId] 

  createView: (viewId, content) =>

    view = new View(this, viewId, content)
    this.views[viewId] = view
    return view

  addSnippet: (name, func) =>
    
    @snippets[name] = func

  @_surroundSnippet: (viewFirst, html, argumentMap)  =>

    console.log("_surroundSnippet invoked with #{html}")
  
    surroundingName = argumentMap['with']
    at = argumentMap['at']
    surroundingView = viewFirst.findView(surroundingName)

    console.log("surroundingView found #{surroundingView.viewId}")
    
    surroundingContent = $("<div>#{surroundingView.getElement()}</div>")
    
    console.log("surroundingContent.html()=#{surroundingContent.html()}")
    
    bindElement = surroundingContent.find("[data-bind-name='#{at}']")
    
    bindElement.replaceWith(html)

    console.log("surroundingContent.html() = #{surroundingContent.html()}")
    
    return surroundingContent.html()

class View

  constructor: (@viewFirst, @viewId, @element) ->

  render: ->
    wrapped = document.createElement("div")
    wrapped.innerHTML = @element
    @applySnippetsRecursivelyToChildren(wrapped)
    #console.log "render returned #{wrappedWithSnippetsApplied.innerHTML}"
    return wrapped.innerHTML

  applySnippetsRecursivelyToChildren: (parent) =>
  
    child = parent.firstChild
    while child
      console.log "in while, applying for #{child.outerHTML}"
      replacedChild = @applySnippetsRecursivelyToChild(parent, child)
      child = replacedChild.nextSibling
    
  applySnippetsRecursivelyToChild: (parent, node) =>
    
    if node.nodeType != 3
    
      console.log "applySnippetsRecursivelyToChild(#{parent},#{node}) parents innerHTML= #{parent.innerHTML}"
  
      replaced = @applySnippetsAndReplace(parent, node)
      child = replaced.firstChild
      while child
        childReplacement = @applySnippetsRecursivelyToChild(replaced, child)
        console.log "childReplacement=#{childReplacement}"
        child = childReplacement.nextSibling
    
    console.log "applySnippetsRecursivelyToChild returned #{replaced}"

    return if replaced then replaced else node
    
  applySnippetsAndReplace: (parent, node) =>

    console.log "applySnippetsAndReplace(#{parent},#{node})"

    placeHolder = document.createElement("p")
    
    parent.replaceChild(placeHolder, node)
    
    tmp = document.createElement("div")
    tmp.appendChild(node)
    nodeAsString = tmp.innerHTML
    withSnippetsApplied = @applySnippets nodeAsString
    console.log("withSnippetsApplied=#{withSnippetsApplied}")
    tmp.innerHTML = withSnippetsApplied
    replacement = tmp.firstChild
    console.log "Trying to replace #{node} with #{tmp.firstChild}"
    parent.replaceChild(replacement, placeHolder)

    console.log "applySnippetsAndReplace returned + #{replacement}"
    return replacement
    
  applySnippets: (element) =>
  
    console.log("applySnippets called on #{element}")
    node = $(element)
    snippetName = node.attr('data-snippet')

    console.log("snippetName=#{snippetName}")
  
    return if snippetName?
      snippetFunc = @viewFirst.snippets[snippetName]
      snippetFunc(@viewFirst, node.html(), node.data())
      #@applySnippetsRecursively(afterSnippetsFuncApplied)
    else
      element
    
    console.log "applySnippets returned #{afterSnippetsApplied}"
    return afterSnippetsApplied  

  getElement: () => @element

  
init = () -> 
  
  viewFirst = new ViewFirst

  #innerView = viewFirst.createView("innerView", '<div data-snippet="surround" data-with="outerView" data-at="content"><p>surrounded!</p></div>')
  innerView = viewFirst.createView("innerView", '<div /><div id="ignoreThis"></div><div id="wrapsEverything"><div id="somethingHere"></div><div data-snippet="surround" data-with="outerView" data-at="content"><p>surrounded!</p></div></div>')
  outerView = viewFirst.createView("outerView", '<div id="outerViewDiv"><div data-bind-name="content" /></div>')
  
  console.log("created views")

  $('body').html(innerView.render())
  
$(init)
