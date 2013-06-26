define [], () ->

  bindParts = (surroundingContent, nodes) ->

    for child in nodes
      at = $(child).attr("data-at")
      bind(surroundingContent, child.childNodes, at) if at?

  bind = (surroundingContent, html, at) ->
    bindElement = surroundingContent.find("[data-bind-name='#{at}']")
    bindElement.replaceWith(html)


  TemplatingSnippets =

    surround: (node, argumentMap) ->

      nodes = node.contents() #This snippet is only interested in child nodes
      console.log "_surroundSnippet invoked with #{node}"

      surroundingName = argumentMap['with']
      at = argumentMap['at']
      surroundingView = @findView(surroundingName)

      unless surroundingView?
        throw "Unable to find surrounding template '#{surroundingName}'"

      surroundingContent = $(surroundingView.getElement())

      if at?
        @bind(surroundingContent, nodes, at)
      else
        @bindParts(surroundingContent, nodes)

      return surroundingContent

    embed: (html, argumentMap) ->

      templateName = argumentMap['view']
      embeddedView = @views[templateName]

      unless embeddedView?
        throw "Unable to find template to embed '#{templateName}'"

      return $("<div>#{embeddedView}</div>").contents()

  return TemplatingSnippets