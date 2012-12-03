createTodoApp = ->

  myTodo = new window.Todo(name: "Cook tea", description: "At some point I'll need to cook some tea")

  viewFirst = new ViewFirst()
  
  yearSnippet = (viewFirst, nodeList, argMap) =>
    
    return document.createTextNode(new Date().getFullYear())  

  todoCreationSnippet = (viewFirst, node, argMap) =>
  
    todo = viewFirst.getOrCreateNamedModel("currentTodo", window.Todo)
    form = $(node)
    
    saveTodo = (aTodo) =>
    
      name = form.children("[data-property='name']").val()
      description = form.children("[data-property='description']").val()

      aTodo.name = name
      aTodo.description = description
      aTodo.save()
      
      return false

    updateForm = (oldTodo, newTodo) =>
    
      #name = form.children("[data-property='name']").val(newTodo.name)
      #description = form.children("[data-property='description']").val(newTodo.description)
      
      ViewFirst.bindNodeValues(node, newTodo)
      
      createTodoButton = form.find("#createTodo")
      createTodoButton.unbind("click.saveTodo")
      createTodoButton.bind("click.saveTodo", (event) ->
        event.preventDefault()
        saveTodo(newTodo)
        )
    
    viewFirst.addNamedModelEventListener("currentTodo", updateForm)
    updateForm(null, todo)
    
    return node

  listTodosSnippet = (viewFirst, node, argMap) =>

    select = $(node)
    select.change(-> viewFirst.setNamedModel("currentTodo", Todo.find(@value)))
  
    template = select.find("option")
    template.detach()
  
    addTodoItem = (todo) =>
      option = template.clone()
      option.attr("value", todo.id)
      viewFirst.bindTextNodes(option.get(0), todo)
      $(node).append(option)
    
    addTodoItem aTodo for aTodo in window.Todo.all()

    return node
        
  viewFirst.addSnippet("todoForm", todoCreationSnippet)
  viewFirst.addSnippet("listTodos", listTodosSnippet)
  viewFirst.addSnippet("year", yearSnippet)
  
  viewFirst.renderView("todo")
  
  alert("There are #{window.Todo.all().length} todos")

$(-> createTodoApp())