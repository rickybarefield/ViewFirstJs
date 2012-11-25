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

  @_surroundSnippet: (viewFirst, html, argumentMap)  =>

    console.log("_surroundSnippet invoked with #{html}")
  
    surroundingName = argumentMap['with']
    at = argumentMap['at']
    surroundingView = viewFirst.findView(surroundingName)

    if(!surroundingView?)
      throw "Unable to find surrounding template '#{surroundingName}'"
    
    surroundingContent = $("<div>#{surroundingView.getElement()}</div>")
    
    if at?
      @_bind(surroundingContent, html, at)
    else
      @_bindParts(surroundingContent, html)
    
    return surroundingContent.html()

  @_bindParts: (surroundingContent, html) =>

    parent = document.createElement("div")
    parent.innerHTML = html
    
    child = parent.firstChild
    while child?
      at = $(child).attr("data-at")
      if(at?)
        @_bind(surroundingContent, child.innerHTML, at)
      child = child.nextSibling
  
  @_bind: (surroundingContent, html, at) =>
    bindElement = surroundingContent.find("[data-bind-name='#{at}']")
    bindElement.replaceWith(html)
    
  @_embedSnippet: (viewFirst, html, argumentMap) =>
  
    templateName = argumentMap['template']
    embeddedView = viewFirst.findView(templateName)
    
    if(!embeddedView?)
      throw "Unable to find template to embed '#{templateName}'"
    
    return embeddedView.render()
