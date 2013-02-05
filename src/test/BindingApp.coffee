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


  viewFirst.addSnippet("simpleBind", simpleBind)
  viewFirst.addSnippet("updateDogsName", updateDogsName)
  viewFirst.addSnippet("changeColour", changeColour)

  viewFirst.initialize()