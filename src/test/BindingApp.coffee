$ ->

  viewFirst = new ViewFirst("main")

  collie = new DogModel()
  collie.set("name", "Alfie")
  collie.set("colour", "Brown")
  collie.set("breed", "Collie")
  collie.set("height", "16 inches")

  collie.save()

  simpleBind = (viewFirst, node, argMap) ->
    viewFirst.bindTextNodes node, collie
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
    viewFirst.bindTextNodes node, nestedDog
    return node
    
  changeCollarColour = (viewFirst, node, argMap) ->
    node.click(-> collar.set("colour", "blue"))
    return node
    


  viewFirst.addSnippet("simpleBind", simpleBind)
  viewFirst.addSnippet("updateDogsName", updateDogsName)
  viewFirst.addSnippet("changeColour", changeColour)

  viewFirst.addSnippet("dogWithCollar", dogWithCollar)
  viewFirst.addSnippet("changeCollarColour", changeCollarColour)

  viewFirst.initialize()