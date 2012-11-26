class window.Todo extends Spine.Model

  @configure "Todo", "name", "description"


window.Todo.extend(Spine.Model.Local);

window.Todo.fetch()