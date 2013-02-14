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

  collie.save()
  alsatian.save()
  
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

  viewFirst.addSnippet("dogRow", dogRow)
  viewFirst.addSnippet("addTerry", addTerry)

  viewFirst.initialize()