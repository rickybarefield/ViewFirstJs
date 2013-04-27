$ ->

  viewFirst = new ViewFirst("main")

  collie = new DogModel()
  collie.set("name", "Alfie")
  collie.set("colour", "Brown")
  collie.set("breed", "Collie")
  collie.set("height", "16 inches")

  collie.save()

  simpleBind = (viewFirst, node, argMap) ->
    viewFirst.bindNodes node, collie
    return node

  updateDogsName = (viewFirst, node, argMap) ->

    updateDogsName = -> collie.set("name", "Donald")
    $(node).click(updateDogsName)
    return node

  changeColour = (viewFirst, node, argMap) ->

    viewFirst.bindNodeValues node, collie

    return node
    
  #Nested
  
  nestedDog = new DogModel
  collar = new Collar
  collar.set("colour", "red")
  nestedDog.set("collar", collar)

  dogWithCollar = (viewFirst, node, argMap) ->
    viewFirst.bindNodes node, nestedDog
    return node
    
  changeCollarColour = (viewFirst, node, argMap) ->
    node.click(-> collar.set("colour", "blue"))
    return node
    
  removeCollar = (viewFirst, node, argMap) ->

    $(node).click(-> nestedDog.set("collar", null))
    return node

  addPinkCollar = (viewFirst, node, argMap) ->
  
    pinkCollar = new Collar
    pinkCollar.set("colour","pink")
    $(node).click(-> nestedDog.set("collar", pinkCollar))
    return node

  viewFirst.addSnippet("simpleBind", simpleBind)
  viewFirst.addSnippet("updateDogsName", updateDogsName)
  viewFirst.addSnippet("changeColour", changeColour)

  viewFirst.addSnippet("dogWithCollar", dogWithCollar)
  viewFirst.addSnippet("changeCollarColour", changeCollarColour)
  viewFirst.addSnippet("removeCollar", removeCollar)    
  viewFirst.addSnippet("addPinkCollar", addPinkCollar)    

  viewFirst.initialize()