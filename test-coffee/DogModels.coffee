define ["DogModel", "backbone.localStorage", "backbone"], (DogModel, BackboneLocalStorage, Backbone) ->
  class window.DogModels extends Backbone.Collection
    model: DogModel
    localStorage: new Store("DogModels")
