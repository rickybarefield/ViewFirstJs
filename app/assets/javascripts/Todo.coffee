class window.Todo extends Backbone.Model

  defaults:
  	name: ""
  	description: ""

class window.Todos extends Backbone.Collection
  model: Todo
  url: "/todos"


window.allTodos = new Todos()

console.log "Here"

allTodos.fetch
  success: (collection) -> console.log "There are now #{collection.length} in the todos"
  error: (collection) -> console.log "There was a real bad error!"