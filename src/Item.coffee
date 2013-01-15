class window.Item extends window.ViewFirstModel

  urlRoot: "/items"

  defaults:
    title: ""
    description: ""

class window.Items extends Backbone.Collection

  model: Item
  url: "/items"

window.allItems = new Items

window.allItems.fetch
  success: (collection) -> console.log("There are now #{collection.length} items")
  error: -> console.log("Something went wrong")