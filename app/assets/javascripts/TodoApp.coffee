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
      deleteButton = todoDiv.children("button")
      deleteButton.click(=>
        if window.confirm("Are you sure?")
          todo.destroy()
          todoDiv.detach())
      todoDiv.get(0)

    viewFirst.bindModel(Todo, node, createItem)
  
    return node

  newTodo = (viewFirst, node, argMap) =>

    $node = $(node)

    createNewTodo = (name) =>
      newTodo = new Todo(name: name, description: "")
      newTodo.save()
    
    $node.keypress( (key) =>
      if key.which == 13 and $node.val()?
        createNewTodo($node.val())
        $node.val(""))

    return node

  todoDescription = (viewFirst, node, argMap) =>

    $node = $(node)
    $node.hide()

    viewFirst.addNamedModelEventListener "currentTodo", (oldModel, newModel) =>
      if newModel?
        viewFirst.bindNodeValues(node, newModel)
        $node.show(100)
      else
        $node.val("")
        $node.hide()

    return node

  todoRow = (viewFirst, node, argMap) =>

    $node = $(node)
    $parent = $node.parent()
    $template = $node.detach()

    viewFirst.bindModel(Todo, $parent, => $template.clone().get(0))

    return null

  viewFirst.addSnippet("todoRow", todoRow)
  viewFirst.addSnippet("todoItems", todoItems)
  viewFirst.addSnippet("todoDescription", todoDescription)
  viewFirst.addSnippet("newTodo", newTodo)
  
  viewFirst.initialize()
  
$(-> createTodoApp())