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
                                                          console.log "Loading script with node=#{node.attr('id')}, html()=#{node.html()}"
                                                          @createView(node.attr("id"), node.html())) 
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
    
    bindElement = surroundingContent.find("[data-bind-name='#{at}']")
    bindElement.replaceWith(html)
    
    return surroundingContent.html()

  @_embedSnippet: (viewFirst, html, argumentMap) =>
  
    templateName = argumentMap['template']
    embeddedView = viewFirst.findView(templateName)
    
    if(!embeddedView?)
      throw "Unable to find template to embed '#{templateName}'"
    
    return embeddedView.render()

init = () -> 

  dateSnippet = (viewFirst, html, argumentMap) ->
      currentDate = new Date()
      return currentDate.getDay() + "-" + currentDate.getMonth() + "-" + currentDate.getFullYear()

  viewFirst = new ViewFirst
  viewFirst.addSnippet("date", dateSnippet)
  
  
  #innerView = viewFirst.createView("innerView", '<div data-snippet="surround" data-with="outerView" data-at="content"><p>Simple</p></div>');
  #outerView = viewFirst.createView("outerView", '<div id="outerViewDiv"><span data-bind-name="content" /></div>')
   
  console.log("created views")
 
  #$('body').html(viewFirst.findView("innerView").render())
  
  viewFirst.renderView("innerView")
  
$(init)
