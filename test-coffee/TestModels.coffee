define ["backbone", "backbone-relational", "TestModel"], (Backbone, BackboneRelational, TestModel) ->

  class TestModels extends Backbone.Collection
    model: TestModel
    localStorage: new Store("TestModels")