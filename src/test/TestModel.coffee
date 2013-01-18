class window.TestModel extends window.ViewFirstModel

  localStorage: new Store("TestModels")  
  url: "/"
  defaults:
  	testProperty: ""


class window.TestModels extends Backbone.Collection
  model: TestModel
  localStorage: new Store("TestModels")