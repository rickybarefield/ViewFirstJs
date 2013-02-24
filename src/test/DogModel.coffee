class window.Collar extends Backbone.RelationalModel

  localStorage: new Store("DogModels")  
  defaults:
    colour: ""
  

class window.DogModel extends Backbone.RelationalModel

  localStorage: new Store("DogModels")  
  url: "/"
  relations: [{
    type: Backbone.HasOne,
    key: 'collar',
    relatedModel: 'Collar'
    }]
  defaults:
    name: ""
    colour: ""
    breed: ""
    height: ""


class window.DogModels extends Backbone.Collection
  model: DogModel
  localStorage: new Store("DogModels")