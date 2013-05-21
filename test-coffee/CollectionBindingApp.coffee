require ["ViewFirst", "jquery", "DogModel", "DogModels"], (ViewFirst, $, DogModel, DogModels) ->
  $ ->
  
    viewFirst = new ViewFirst("main")
  
    collie = new DogModel()
    collie.set("name", "Colin")
    collie.set("colour", "Brown")
    collie.set("breed", "Collie")
    collie.set("height", "16 inches")
  
    alsatian = new DogModel()
    alsatian.set("name", "Alfie")
    alsatian.set("colour", "Black")
    alsatian.set("breed", "Alsatian")
    alsatian.set("height", "20 inches")
  
    alsatian.save()
    collie.save()
    
    dogs = new DogModels()
    
    dogs.add(collie)
    dogs.add(alsatian)
  
    dogRow = (viewFirst, node, argMap) ->
      
      createNode = (dog) -> node.clone()
    
      viewFirst.bindCollection dogs, node.parent(), createNode
   
      return null
  
    addTerry = (viewFirst, node, argMap) ->
    
      node.click(->
        terry = new DogModel()
        terry.set("name", "Terry")
        terry.set("colour", "Grey")
        terry.set("breed", "Terrier")
        terry.set("height", "5 inches")
        dogs.add(terry))
      
      node
  
    removeColin = (viewFirst, node, argMap) ->
    
      node.click(-> dogs.remove(collie))
      
      node
  
    viewFirst.addSnippet("dogRow", dogRow)
    viewFirst.addSnippet("addTerry", addTerry)
    viewFirst.addSnippet("removeColin", removeColin)
  
    viewFirst.initialize()