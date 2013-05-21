define ["backbone-relational", "backbone.localStorage", "backbone", "Collar"], (BackboneRelational, BackboneLocalStorage, Backbone, Collar) ->
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
      
      return false #TODO if errors.length > 0 then errors else false
