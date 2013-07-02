define ["ViewFirstModel", "ViewFirstRouter", "ViewFirstModelContainer", "BindHelpers", "TemplatingSnippets", "OneToMany", "ManyToOne", "ViewFirstConverters"], (ViewFirstModel, ViewFirstRouter, ModelContainer, BindHelpers, TemplatingSnippets, OneToMany, ManyToOne, ViewFirstConverters) ->
  
  class ViewFirst extends BindHelpers

    _target: "body"

    @Model = ViewFirstModel
    @OneToMany = OneToMany
    @ManyToOne = ManyToOne

    dateFormat: "dd/MM/yyyy"
    
    constructor: () ->

      @views = {}
      @namedModels = {}
      @router = new ViewFirstRouter(this)
      @snippets = {}
      @addSnippet(key, value) for key, value of TemplatingSnippets
      ViewFirstConverters(@)
      $('script[type="text/view-first-template"]').each (id, el) =>
        node = $(el)
        viewName = node.attr("name")
        @views[viewName] = node.html()
        #TODO @router.addRoute viewName, viewName == @indexView

    initialize: ->


      #TODO Backbone.history.start()

    render: (viewId) ->

      @currentView = viewId
      viewElement = @views[viewId]
      throw "Unable to find view: #{viewId}" unless viewElement?
      inflated = @inflate(viewElement)
      $(@_target).html inflated

    navigate: (viewId) ->
      Backbone.history.navigate viewId, true

    addSnippet: (name, func) ->
      @snippets[name] = func

    setNamedModel: (name, model, dontSerialize = false) ->

      @namedModels[name] = new ModelContainer() unless @namedModels[name]?
      modelContainer = @namedModels[name]
      modelContainer.set(model)

      #TODO @router.updateState() unless dontSerialize

    getNamedModel: (name) ->

      modelContainer = @namedModels[name]
      return if modelContainer? then modelContainer.model else null

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
      snippetName = node.data('snippet')

      if snippetName?
        snippetFunc = @snippets[snippetName]
        throw "Unable to find snippet '#{snippetName}'" unless snippetFunc?

        node.data("snippet", null) # Otherwise this will be recursively invoked

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
