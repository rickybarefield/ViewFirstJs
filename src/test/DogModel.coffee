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
    
  validate: (attrs) ->
  
    errors = []
    if !attrs.age? or attrs.age == ""
      errors.push {name: 'age', message: 'Age must be set'}
    
    return if errors.length > 0 then errors else false
    
class window.DogModels extends Backbone.Collection
  model: DogModel
  localStorage: new Store("DogModels")
  
class window.Collars extends Backbone.Collection
  model: Collar
  localStorage: new Store("DogModels")
  