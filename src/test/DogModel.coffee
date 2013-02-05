class window.DogModel extends window.ViewFirstModel

  localStorage: new Store("DogModels")  
  url: "/"
  defaults:
    name: ""
    colour: ""
    breed: ""
    height: ""


class window.DogModels extends Backbone.Collection
  model: DogModel
  localStorage: new Store("DogModels")