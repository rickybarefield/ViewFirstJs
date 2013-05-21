require ["ViewFirst", "jquery", "DogModel", "Collar", "Collars"], (ViewFirst, $, DogModel, Collar, Collars) ->

  $ ->
  
    viewFirst = new ViewFirst("main")
  
    collie = new DogModel()
    collie.set("name", "Alfie")
    collie.set("breed", "Collie")
    collie.save()
  
    collars = new Collars
    
    redCollar = new Collar
    redCollar.set("colour", "red")
    collars.add(redCollar)
  
    blueCollar = new Collar
    blueCollar.set("colour", "blue")
    collars.add(blueCollar)
  
    yellowCollar = new Collar
    yellowCollar.set("colour", "yellow")
    collars.add(yellowCollar)
  
    collie.set("collar", yellowCollar)
  
    bindCollieToInputs = (viewFirst, node, argMap) ->
      viewFirst.bindNodeValues node, collie, "collars": collars
      return node
  
    bindCollie = (viewFirst, node, argMap) ->
      viewFirst.bindNodes node, collie
      return node
  
    viewFirst.addSnippet("bindCollie", bindCollie)    
    viewFirst.addSnippet("bindCollieToInputs", bindCollieToInputs)    
  
    viewFirst.initialize()