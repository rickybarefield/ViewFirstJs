$ ->

  viewFirst = new ViewFirst("todo")

  todoItems = (viewFirst, node, argMap) ->

    $node = $(node)
    template = $node.children("div")
    template.detach()

    viewFirst.bindModel allTodos, node, (todo) ->

      todoDiv = template.clone()
      input = todoDiv.children("input")

      todoDiv.dblclick ->
        input.addClass("editing")
        input.prop("disabled", false)
        input.focus()

      input.blur ->
        input.removeClass("editing")
        input.prop("disabled", true)

      input.keypress (key) ->
        input.blur() if key.which is 13

      input.focus ->
        viewFirst.setNamedModel("currentTodo", todo)

      deleteButton = todoDiv.children "button"
      deleteButton.click ->
        if window.confirm "Are you sure?"
          todo.destroy()
          todoDiv.detach()

      todoDiv.get(0)
  
    return node


  newTodo = (viewFirst, node, argMap) ->

    $node = $(node)

    $node.keypress (key) ->
      name = $node.val()
      if key.which is 13 and name?
        newTodo = new Todo(name: name, description: "")
        console.log "adding"
        allTodos.add newTodo
        newTodo.save()
        $node.val("")

    return node


  todoDescription = (viewFirst, node, argMap) ->

    $node = $(node)
    $node.hide()

    viewFirst.addNamedModelEventListener "currentTodo", (oldModel, newModel) ->
      if newModel?
        viewFirst.bindNodeValues(node, newModel)
        $node.show 100
      else
        $node.val ""
        $node.hide()

    return node


  todoRow = (viewFirst, node, argMap) ->

    $node = $(node)
    $parent = $node.parent()
    $template = $node.detach()

    viewFirst.bindModel allTodos, $parent, ->
      $template.clone().get(0)

    return null


  viewFirst.addSnippet("todoRow", todoRow)
  viewFirst.addSnippet("todoItems", todoItems)
  viewFirst.addSnippet("todoDescription", todoDescription)
  viewFirst.addSnippet("newTodo", newTodo)
  
  viewFirst.initialize()
  
