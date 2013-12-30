bindParts = (surroundingContent, nodes) ->

  for child in nodes
    at = $(child).attr("data-at")
    bind(surroundingContent, child.childNodes, at) if at?

bind = (surroundingContent, html, at) ->
  bindElement = surroundingContent.find("[data-bind-name='#{at}']")
  bindElement.replaceWith(html)

module.exports =

  surround: (node, argumentMap) ->

    nodes = node.contents() #This snippet is only interested in child nodes
    #console.log "_surroundSnippet invoked with #{node}"

    surroundingName = argumentMap['with']
    at = argumentMap['at']
    surroundingView = @views[surroundingName]

    unless surroundingView?
      throw "Unable to find surrounding view '#{surroundingName}'"

    surroundingContent = $("<div>#{surroundingView}</div>")

    if at?
      bind(surroundingContent, nodes, at)
    else
      bindParts(surroundingContent, nodes)

    return surroundingContent.contents()

  embed: (html, argumentMap) ->

    templateName = argumentMap['view']
    embeddedView = @views[templateName]

    unless embeddedView?
      throw "Unable to find template to embed '#{templateName}'"

    return $("<div>#{embeddedView}</div>").contents()
