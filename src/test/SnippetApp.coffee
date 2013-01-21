$ ->

  viewFirst = new ViewFirst("simplyInvoke")

  simplyInvoke = (viewFirst, node, argMap) ->
    $node = $(node)
    $node.text("Was Invoked")
    return node
 
  incrementingNumber = 1

  number = (viewFirst, node, argMap) ->
    $(node).children("p").children("span").text(incrementingNumber++)
    return node

  upToTen = (viewFirst, node, argMap) ->

    startingFrom = argMap["startingFrom"]
    newSnippet = if startingFrom != 10 then "<span data-snippet=\"upToTen\" data-starting-from=\"#{startingFrom + 1}\"></span>" else ""
    return $("<p>#{startingFrom.toString()}</p>#{newSnippet}").get()


  viewFirst.addSnippet("simplyInvoke", simplyInvoke)
  viewFirst.addSnippet("upToTen", upToTen)
  viewFirst.addSnippet("number", number)

  viewFirst.initialize()