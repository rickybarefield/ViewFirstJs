define [], () ->
  class TemplatingSnippets

    @add: (viewFirst) ->
      viewFirst.addSnippet "surround", @surroundSnippet
      viewFirst.addSnippet "embed", @embedSnippet


    @surroundSnippet: (viewFirst, node, argumentMap) =>

      nodes = node.contents() #This snippet is only interested in child nodes
      console.log "_surroundSnippet invoked with #{node}"

      surroundingName = argumentMap['with']
      at = argumentMap['at']
      surroundingView = viewFirst.findView(surroundingName)

      unless surroundingView?
        throw "Unable to find surrounding template '#{surroundingName}'"

      surroundingContent = $(surroundingView.getElement())

      if at?
        @bind(surroundingContent, nodes, at)
      else
        @bindParts(surroundingContent, nodes)

      return surroundingContent

    @bindParts: (surroundingContent, nodes) ->

      for child in nodes
        at = $(child).attr("data-at")
        @bind(surroundingContent, child.childNodes, at) if at?

    @bind: (surroundingContent, html, at) ->
      bindElement = surroundingContent.find("[data-bind-name='#{at}']")
      bindElement.replaceWith(html)


    @embedSnippet: (viewFirst, html, argumentMap) ->

      templateName = argumentMap['template']
      embeddedView = viewFirst.findView(templateName)

      unless embeddedView?
        throw "Unable to find template to embed '#{templateName}'"

      return $(embeddedView.getElement()).clone()
  