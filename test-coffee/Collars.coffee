define ["backbone-relational", "backbone.localStorage", "backbone", "Collar"], (BackboneRelational, BackboneLocalStorage, Backbone, Collar) ->

  class window.Collars extends Backbone.Collection
    model: Collar
    localStorage: new Store("DogModels")
    