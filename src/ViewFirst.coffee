define ["View", "ViewFirstRouter", "BindHelpers", "TemplatingSnippets"], (View, ViewFirstRouter, BindHelpers, TemplatingSnippets) ->
  class ViewFirst extends BindHelpers
  
    @TEXT_NODE = 3
    @ATTR_NODE = 2
  
    ###
      namedModelEventListeners contain a map of namedModel name to array of event handlers
    ###
    constructor: (@indexView,
      @views = {}, 
      @namedModels={}, 
      @namedModelEventListeners={}, 
      @router = new ViewFirstRouter(this),
      @snippets = {}) ->
      
      TemplatingSnippets.add(this)
  
  
    initialize: ->
  
      $('script[type="text/view-first-template"]').each (id, el) =>
        node = $(el)
        console.log "Loading script with id=#{node.attr 'name' }"
        viewName = node.attr("name")
        @createView viewName , node.html()
        @router.addRoute viewName, viewName == @indexView
  
      Backbone.history.start()
  
  
    findView: (viewId) ->
      @views[viewId]
  
  
    renderView: (viewId) ->
  
      @currentView = viewId
      view = @findView viewId
      rendered = view.render()
      $('body').html rendered
  
    navigate: (viewId) ->
      Backbone.history.navigate viewId, true
  
    createView: (viewId, content) ->
  
      view = new View(this, viewId, content)
      @views[viewId] = view
      return view
  
  
    addSnippet: (name, func) ->
      @snippets[name] = func
  
  
    setNamedModel: (name, model, dontSerialize = false) ->
  
      oldModel = @namedModels[name]
  
      if model?
        @namedModels[name] = model
        model.constructor.bind("destroy", => @setNamedModel(name, null))
      else
        delete @namedModels[name]
  
      console.log "named model set"
  
      @router.updateState() unless dontSerialize
  
      eventListenerArray = @namedModelEventListeners[name]
  
      if eventListenerArray?
        func(oldModel, model) for func in eventListenerArray
  
    addNamedModelEventListener: (name, func) ->
  
      eventListenerArray = @namedModelEventListeners[name]
  
      unless eventListenerArray?
        eventListenerArray = []
        @namedModelEventListeners[name] = eventListenerArray
  
      eventListenerArray.push(func)
