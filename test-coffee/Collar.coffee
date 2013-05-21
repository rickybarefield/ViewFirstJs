define ["backbone-relational", "backbone.localStorage", "backbone"], (BackboneRelational, BackboneLocalStorage, Backbone) ->

  class window.Collar extends Backbone.RelationalModel
  
    localStorage: new Store("DogModels")  
    defaults:
      colour: ""
