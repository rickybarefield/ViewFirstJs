define ["ViewFirstModel", "ViewFirstRouter", "ViewFirstModelContainer", "BindHelpers", "OneToMany", "ManyToOne"], (ViewFirstModel, ViewFirstRouter, ModelContainer, BindHelpers, OneToMany, ManyToOne) ->
  
  class ViewFirst extends BindHelpers

    @Model = ViewFirstModel
    @OneToMany = OneToMany
    @ManyToOne = ManyToOne
    
    constructor: (@indexView) ->

      @views = {}
      @namedModels = {}
      @router = new ViewFirstRouter(this)
      @snippets = {}
      @addSnippet(key, value) for key, value of TemplatingSnippets

    initialize: ->

      $('script[type="text/view-first-template"]').each (id, el) =>
        node = $(el)
        console.log "Loading script with id=#{node.attr 'name' }"
        viewName = node.attr("name")
        @views[viewName] node.html()
        @router.addRoute viewName, viewName == @indexView

      Backbone.history.start()

    renderView: (viewId) ->

      @currentView = viewId
      viewElement = @views[viewId]
      inflated = @inflate(viewElement)
      $('body').html inflated

    navigate: (viewId) ->
      Backbone.history.navigate viewId, true

    addSnippet: (name, func) ->
      @snippets[name] = func

    setNamedModel: (name, model) ->

      @namedModels[name] = new ModelContainer() unless @namedModels[name]?
      modelContainer = @namedModels[name]
      modelContainer.set(model)

      @router.updateState() unless dontSerialize

    onNamedModelChange: (name, func) ->

      @namedModels[name] = new ModelContainer() unless @namedModels[name]?
      modelContainer = @namedModels[name]
      modelContainer.on("change", func)

    inflate: (element) ->
      nodes = $("<div>#{element}</div>")
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
        snippetFunc = @snippets[snippetName]
        throw "Unable to find snippet '#{snippetName}'" unless snippetFunc?

        node.removeAttr("data-snippet") # Otherwise this will be recursively invoked

        nodeAfterSnippetApplied = snippetFunc.call(this, node, parentsAndNodesAttributes)

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
