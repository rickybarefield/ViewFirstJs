class window.Todo extends Spine.Model

  @configure "Todo", "name", "description"

  @extend(Spine.Model.Ajax);

  @url: "/todos"




window.Todo.fetch()
