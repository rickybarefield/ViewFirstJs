createTodoApp = ->

  myTodo = new window.Todo(name: "Cook tea", description: "At some point I'll need to cook some tea")

  viewFirst = new ViewFirst()
  
  dateSnippet = (viewFirst, nodeList, argMap) =>
  
    p = document.createElement("p")
    p.innerHTML = new Date().toString()
    return p
  

  yearSnippet = (viewFirst, nodeList, argMap) =>
    
    return document.createTextNode(new Date().getFullYear())
  

  todoCreationSnippet = (viewFirst, nodeList, argMap) =>
  
    nodesInJQuery = $(nodeList)
    newTodo = new window.Todo()
    
    updateAndSaveTodo = (aForm) =>
    
      name = aForm.children("[data-property='name']").val()
      description = aForm.children("[data-property='description']").val()

      newTodo.name = name
      newTodo.description = description
      newTodo.save()
      
      alert("Saved this todo, you'll need to refresh the browser to see it!")
      
      return false
      
    form = nodesInJQuery.filter("#createTodoForm")

    nodesInJQuery.find("#createTodo").click((event) ->
      event.preventDefault()
      updateAndSaveTodo(form)
      )
    
    return nodeList

  listTodosSnippet = (viewFirst, nodeList, argMap) =>
  
    createTodoItem = (todo) =>
      clonedNodes = $(nodeList).clone()
      clonedNodes.find("[data-property='name']").replaceWith(todo.name)
      clonedNodes.find("[data-property='description']").replaceWith(todo.description)
      clonedNodes.get()
    
    
    todoNodes = (createTodoItem aTodo for aTodo in window.Todo.all())
    todoNodes = [] unless todoNodes?

    return todoNodes
        
  viewFirst.addSnippet("todoForm", todoCreationSnippet)
  viewFirst.addSnippet("listTodos", listTodosSnippet)
  viewFirst.addSnippet("year", yearSnippet)
  viewFirst.addSnippet("date", dateSnippet)

  viewFirst.renderView("todo")
  
  alert("There are #{window.Todo.all().length} todos")

$(-> createTodoApp())