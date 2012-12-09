createTodoApp = ->

  viewFirst = new ViewFirst("todo")

  todoItems = (viewFirst, node, argMap) =>

    $node = $(node)
    template = $node.children("div")
    template.detach()

    createItem = (todo) =>
      todoDiv = template.clone()
      input = todoDiv.children("input")
      todoDiv.dblclick(=>
        input.addClass("editing")
        input.prop("disabled", false)
        input.focus())
      input.blur(=>
        input.removeClass("editing")
        input.prop("disabled", true))
      input.keypress((key) ->
        if key.which == 13 then input.blur())
      input.focus(=> viewFirst.setNamedModel("currentTodo", todo))
      todoDiv.get(0)

    viewFirst.bindModel(Todo, node, createItem)
  
    return node

  newTodo = (viewFirst, node, argMap) =>
    return node

  todoDescription = (viewFirst, node, argMap) =>

    viewFirst.addNamedModelEventListener "currentTodo", (oldModel, newModel) => viewFirst.bindNodeValues(node, newModel)

    return node


  viewFirst.addSnippet("todoItems", todoItems)
  viewFirst.addSnippet("todoDescription", todoDescription)
  viewFirst.addSnippet("newTodo", newTodo)

  
  viewFirst.initialize()
  
$(-> createTodoApp())