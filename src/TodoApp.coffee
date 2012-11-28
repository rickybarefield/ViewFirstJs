createTodoApp = ->

  myTodo = new window.Todo(name: "Cook tea", description: "At some point I'll need to cook some tea")

  viewFirst = new ViewFirst()
  
  yearSnippet = (viewFirst, nodeList, argMap) =>
    
    return document.createTextNode(new Date().getFullYear())
  

  todoCreationSnippet = (viewFirst, nodeList, argMap) =>
  
    nodesInJQuery = $(nodeList)

    todo = viewFirst.getOrCreateNamedModel("currentTodo", window.Todo)
    form = nodesInJQuery.filter("#createTodoForm")
    
    saveTodo = (aTodo) =>
    
      name = form.children("[data-property='name']").val()
      description = form.children("[data-property='description']").val()

      aTodo.name = name
      aTodo.description = description
      aTodo.save()
      
      alert("Saved this todo, you'll need to refresh the browser to see it!")
      
      return false

    updateForm = (oldTodo, newTodo) =>
    
      name = form.children("[data-property='name']").val(newTodo.name)
      description = form.children("[data-property='description']").val(newTodo.description)
      
      createTodoButton = nodesInJQuery.find("#createTodo")
      createTodoButton.unbind("click.saveTodo")
      createTodoButton.bind("click.saveTodo", (event) ->
        event.preventDefault()
        saveTodo(newTodo)
        )
    
    
    
    viewFirst.addNamedModelEventListener("currentTodo", updateForm)
    updateForm(null, todo)
    
    return nodeList

  listTodosSnippet = (viewFirst, nodeList, argMap) =>
  
    createTodoItem = (todo) =>
      clonedNodes = $(nodeList).clone()
      clonedNodes.filter("li").click(-> viewFirst.setNamedModel("currentTodo", todo))
      clonedNodes.find("[data-property='name']").replaceWith(todo.name)
      clonedNodes.find("[data-property='description']").replaceWith(todo.description)
      clonedNodes.get()
    
    todoNodes = (createTodoItem aTodo for aTodo in window.Todo.all())
    todoNodes = [] unless todoNodes?

    return todoNodes
        
  viewFirst.addSnippet("todoForm", todoCreationSnippet)
  viewFirst.addSnippet("listTodos", listTodosSnippet)
  viewFirst.addSnippet("year", yearSnippet)
  
  viewFirst.renderView("todo")
  
  alert("There are #{window.Todo.all().length} todos")

$(-> createTodoApp())