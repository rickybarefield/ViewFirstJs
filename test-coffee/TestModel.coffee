define ["ViewFirstModel", "backbone.localStorage"], (ViewFirstModel, BackboneLocalStorage) ->

  class TestModel extends ViewFirstModel
  
    localStorage: new Store("TestModels")  
    url: "/"
    defaults:
    	testProperty: ""
    	
  window.TestModel = TestModel