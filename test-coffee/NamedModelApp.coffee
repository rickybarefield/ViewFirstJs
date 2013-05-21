require ["ViewFirst", "jquery", "TestModel", "TestModels"], (ViewFirst, $, TestModel, TestModels) ->
  $ ->
  
    viewFirst = new ViewFirst("main")
  
    namedModel1 = new TestModel()
    namedModel1.set("testProperty", "originalValue")
    namedModel1.set("id", 1)
  
    namedModel2 = new TestModel()
    namedModel2.set("testProperty", "newValue")
    namedModel2.set("id", 2)
  
    namedModel1.save()
    namedModel2.save()
  
    testModelCollection = new TestModels
  
    testModelCollection.add(namedModel1)
    testModelCollection.add(namedModel2)
  
    setOriginalNamedModel = (viewFirst, node, argMap) ->
      $node = $(node)
      $node.click(-> viewFirst.setNamedModel("aName", namedModel1))
      return node
  
    updateNamedModel = (viewFirst, node, argMap) ->
  
      $node = $(node)
      $node.click(-> viewFirst.setNamedModel("aName", namedModel2))
      return node
  
    clearNamedModel = (viewFirst, node, argMap) ->
      $node = $(node)
      $node.click(-> viewFirst.setNamedModel("aName", null))
      return node
  
    showNotifications = (viewFirst, node, argMap) ->
  
      $node = $(node)
      oldModelParagraph = $node.find("p#oldModelParagraph")
      newModelParagraph = $node.find("p#newModelParagraph")
  
      viewFirst.addNamedModelEventListener "aName", (oldModel, newModel) -> 
        oldModelParagraph.text(if oldModel? then oldModel.get("testProperty") else "")
        newModelParagraph.text(if newModel? then newModel.get("testProperty") else "")
  
      return node
   
    viewFirst.addSnippet("updateNamedModel", updateNamedModel)
    viewFirst.addSnippet("clearNamedModel", clearNamedModel)
    viewFirst.addSnippet("showNotifications", showNotifications)
    viewFirst.addSnippet("setOriginalNamedModel", setOriginalNamedModel)
  
    viewFirst.initialize()