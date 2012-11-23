class ViewFirst

  constructor: (@views = {}) ->
    @snippets = {
      surround: ViewFirst._surroundSnippet
      }

  findView: (viewId) => this.views[viewId] 

  createView: (viewId, content) =>

    view = new View(this, viewId, content)
    this.views[viewId] = view
    return view

  addSnippet: (name, func) =>
    
    this.snippets[name] = func

  @_surroundSnippet: (viewFirst, children, argumentMap)  =>

    alert("surround invoked")
  
    surroundingName = argumentMap['with']
    
    alert("surrounding name was #{surroundingName}")
    
    at = argumentMap['at']
    
    alert("at #{at}");
    
    surroundingView = viewFirst.findView(surroundingName)

    surroundingContent = surroundingView.getContent

    alert("Content of surrounding view was #{surroundingContent}")
    
    surroundingContent.find("[data-bind-name='#{at}']").replaceWith(children)

    alert("surroundingContent looks like #{surroundingContent.html()}")
    
    return surroundingContent

class View

  constructor: (@viewFirst, @viewId, @content) ->

  render: -> 
    alert('about to render' + @content)
    @content.each(@applySnippets)
    
  applySnippets: (index, element) =>

    node = $(element)
  
    alert('applySnippets ' + node)
    
    snippetName = node.attr('data-snippet')

    alert(snippetName)
    
    if snippetName?
      snippetFunc = @viewFirst.snippets[snippetName]
      alert("Found snippet function: " + snippetFunc)
      replacement = @render(snippetFunc(@viewFirst, node.children(), node.data()))
      node.replaceWith(replacement)

  getContent: (@content) =>

  
init = () -> 
  
  
  viewFirst = new ViewFirst


  innerView = viewFirst.createView("innerView", $('<div data-snippet="surround" data-with="outerView" data-at="content">surrounded!</div>'))

  outerView = viewFirst.createView("outerView", $('<body><div data-bind-name="content" /></body>'))

  alert("Hey")

  $('body').replaceWith(innerView.render())
  
$(init)
