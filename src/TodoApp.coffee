createTodoApp = ->

  myTodo = new window.Todo(name: "Cook tea", description: "At some point I'll need to cook some tea")

  viewFirst = new ViewFirst()
  
  dateSnippet = (viewFirst, nodeList, argMap) =>
  
    p = document.createElement("p")
    p.innerHTML = new Date().toString()
    return p
  
  viewFirst.addSnippet("date", dateSnippet)
  
  ###  
  bindTodoForm = (viewFirst, html, argMap) =>
  
    newTodo = new window.Todo()
  
    
  
    handleSubmission = (form) =>
      
      $(form).find("input").each(consumeInput)

    consumeInput = (index, element) =>
      
      node = $(element)
      property = node.attr("data-property")
      if(property)
        newTodo.set(property, element.value)
  ###  
      
  viewFirst.renderView("todo")


$(-> createTodoApp())