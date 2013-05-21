require ["ViewFirst", "jquery"], (ViewFirst, $) ->

  $ ->
  
    viewFirst = new ViewFirst("routingHome")
  
    renderOtherView = (viewFirst, node, argMap) ->
      $(node).click(-> viewFirst.navigate("otherView"))
      node
  
    viewFirst.addSnippet("renderOtherView", renderOtherView)
    viewFirst.initialize()
