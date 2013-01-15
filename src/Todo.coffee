class window.Todo extends window.ViewFirstModel

  urlRoot: "/todos"

  defaults:
  	name: ""
  	description: ""

class window.Todos extends Backbone.Collection
  model: Todo
  url: "/todos"


window.allTodos = new Todos()

allTodos.fetch
  success: (collection) -> console.log "There are now #{collection.length} in the todos"
  error: (collection) -> console.log "There was a real bad error!"