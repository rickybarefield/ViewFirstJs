define ["ViewFirstModel", "ViewFirst", "House", "Postman", "Room", "expect", "mocha", "JQueryTestHarness", "underscore", "jquery"],
 (ViewFirstModel, ViewFirst, House, Postman, Room, expect, mocha, JQueryTestHarness, _, $) ->

  mocha.setup('tdd')
  
  assert = new expect.Assertion

  aHouse = {}
  kitchen = {}
  bedroom = {}
  fred = {}
  expectedKitchenJson = {}
  expectedBedroomJson = {}
  expectedPostmanJson = {}
  expectedHouseJson = {}
  viewFirst = {}

  createHouse = ->
 
    aHouse = new House() 
    kitchen = new Room()
    bedroom = new Room()
    fred = new Postman()
    fred.set "name", "Fred"
    fred.set "id", 99
    bedroom.set "colour", "Pink"
    bedroom.set "size", 4
    kitchen.set "colour", "White"
    kitchen.set "size", 12
    aHouse.set "doorNumber", 23
    aHouse.set "postman", fred
    aHouse.add "rooms", bedroom
    aHouse.add "rooms", kitchen
    expectedKitchenJson = {"colour":"White","size":12}
    expectedBedroomJson = {"colour":"Pink", "size":4}
    expectedPostmanJson = {"id":99} #ManyToOne relationships should only send the id
    expectedHouseJson = {"doorNumber": 23, "postman": expectedPostmanJson, "rooms":[expectedBedroomJson, expectedKitchenJson]}

  ajaxExpectation = (urlExpected, httpMethod, data, jsonToReturn) ->
    
    dataToReturn = ""
    successCallback = -> throw "Attempted to do callback but ajax was not called first"
    successThis = null
    
    ajaxMethod = (url, options) ->
      expect(urlExpected).to.equal url
      expect(options["type"]).to.equal httpMethod
      if data?
        expect(options["data"]).to.eql data
      successThis = this
      successCallback = options["success"]
                  
    doCallback = ->
      successCallback.call(successThis, jsonToReturn, "200")
    
    return [ajaxMethod, doCallback]

  cloneWithId = (obj, idToAdd) -> $.extend(true, {id: idToAdd}, obj)

  createHouseJsonReturnedOnSave = ->
    clonedHouseJson = cloneWithId(expectedHouseJson, 1)
    clonedHouseJson.rooms[0].id = 2
    clonedHouseJson.rooms[1].id = 3
    return clonedHouseJson

      
    return [ajaxMethod, doCallback]
  
  suite 'ViewFirst Tests', ->
    
    setup ->
      House.instances = []
      Room.instances = []
      createHouse() 
      viewFirst = new ViewFirst()

    suite 'ViewFirst Model Tests', ->
  
  
      suite 'JSON creation', ->
  
        test 'The JSON from a model with only basic properties', ->
    
          expect(kitchen.asJson()).to.eql expectedKitchenJson
        
        test 'A more complex model with OneToMany and ManyToOne relationships', ->
  
          expect(aHouse.asJson()).to.eql expectedHouseJson
  
  
      suite 'Saving a new object', ->
      
        test 'Saving a model with only basic properties', ->
  
          [dummyAjaxFunc, callback] = ajaxExpectation("rooms", "POST", expectedKitchenJson, JSON.stringify(cloneWithId(expectedKitchenJson, 13)))
          JQueryTestHarness.addExpectation($, "ajax", dummyAjaxFunc)
          kitchen.save()
          callback()
          expect(kitchen.get("id")).to.equal(13)
          JQueryTestHarness.assertAllExpectationsMet()
  
        test 'Saving a more complex model with OneToMany and ManyToOne relationships', ->
  
          jsonForServerToReturn = createHouseJsonReturnedOnSave()
          
          #Check our test setup has not changed the original models
          expect(aHouse.get("id")).to.equal null
          expect(bedroom.get("id")).to.equal null
          expect(kitchen.get("id")).to.equal null
  
          [dummyAjaxFunc, callback] = ajaxExpectation("houses", "POST", expectedHouseJson, JSON.stringify(jsonForServerToReturn)) 
          JQueryTestHarness.addExpectation($, "ajax", dummyAjaxFunc)
  
          aHouse.save()
          callback()
          JQueryTestHarness.assertAllExpectationsMet()
          
          #Now check the ids have been applied
          expect(aHouse.get("id")).to.equal 1
          expect(bedroom.get("id")).to.equal 2
          expect(kitchen.get("id")).to.equal 3
  
  
      suite 'Updating and Deleting an object and persisting those changes', ->
  
        initiallySaveTheHouse = ->
          jsonForServerToReturnOnSave = createHouseJsonReturnedOnSave()
          [dummyAjaxFunc, callback] = ajaxExpectation("houses", "POST", expectedHouseJson, JSON.stringify(jsonForServerToReturnOnSave)) 
          JQueryTestHarness.addExpectation($, "ajax", dummyAjaxFunc)
          aHouse.save()        
          callback()
          JQueryTestHarness.assertAllExpectationsMet()
          
        test 'Basic changed attributes are sent in a PUT request', ->
  
          initiallySaveTheHouse()
          
          #Make some changes
          aHouse.set("doorNumber", 99)
  
          expectedJson = {id: 1, doorNumber: 99}
          dummyServerResponse = JSON.stringify(aHouse.asJson())
          [dummyAjaxFunc, callback] = ajaxExpectation("houses/1", "PUT", expectedJson, dummyServerResponse) 
          JQueryTestHarness.addExpectation($, "ajax", dummyAjaxFunc)
          aHouse.save()
          callback()
          JQueryTestHarness.assertAllExpectationsMet()
  
        test 'Deleting a model creates a DELETE request', ->
        
          initiallySaveTheHouse()
  
          [dummyAjaxFunc, callback] = ajaxExpectation("houses/1", "DELETE", null, null) 
          JQueryTestHarness.addExpectation($, "ajax", dummyAjaxFunc)
          aHouse.delete()
          callback()
          JQueryTestHarness.assertAllExpectationsMet()
          
      suite 'Events are fired by models', ->
      
        test 'When a property changes a change event should be fired with the old and new value of the property', ->
        
          changeCalled = false
        
          aHouse.onPropertyChange("doorNumber", (oldValue, newValue) -> 
          
            expect(oldValue).to.equal 23
            expect(newValue).to.equal 12
            changeCalled = true)
            
          aHouse.set("postman", new Postman())
          
          expect(changeCalled).to.equal false
          
          aHouse.set("doorNumber", 12)
          
          expect(changeCalled).to.equal true
    
    suite 'Collection Tests', ->

      suite 'Creating collections and modifying their contents', ->

        test 'I can create a collection of houses and it will contain all the house models I have created', ->
        
          aHouseCollection = House.createCollection()
          expect(aHouseCollection.size()).to.equal 1
          expect(aHouseCollection.getAll()[0]).to.equal aHouse
          
        test 'Creating a new house will add it to an existing collection', ->
        
          aHouseCollection = House.createCollection()
          expect(aHouseCollection.size()).to.equal 1
          anotherHouse = new House()
          expect(aHouseCollection.size()).to.equal 2
    
    suite 'Binding Tests', ->
    
      suite 'Text Binding', ->
    
        test 'A text node should be bound using the # syntax', ->
        
          linkWithTextNode = $('<a>#{doorNumber}</a>')
          viewFirst.bindTextNodes(linkWithTextNode, aHouse)
          
          expect(linkWithTextNode.get(0).outerHTML).to.eql "<a>23</a>"
          
          aHouse.set("doorNumber", 98)
          expect(linkWithTextNode.get(0).outerHTML).to.eql "<a>98</a>"
          
          
        test 'A text node should be bound using the # syntax when there are two # in the same text', ->
        
          linkWithTwoBinds = $('<a>#{colour} - #{size}</a>')
          viewFirst.bindTextNodes(linkWithTwoBinds, bedroom)
          
          expect(linkWithTwoBinds.get(0).outerHTML).to.eql "<a>Pink - 4</a>"
          
          bedroom.set("colour", "Orange")
          
          expect(linkWithTwoBinds.get(0).outerHTML).to.eql "<a>Orange - 4</a>"
          
          bedroom.set("size", 12)
          
          expect(linkWithTwoBinds.get(0).outerHTML).to.eql "<a>Orange - 12</a>"
          
        test 'Attributes should be bound', ->
        
          spanWithAttribute = $("<span class=\"\#{colour}\">Bedroom</span>")
          
          viewFirst.bindTextNodes(spanWithAttribute, bedroom)
          
          expect(spanWithAttribute.get(0).outerHTML).to.eql "<span class=\"Pink\">Bedroom</span>"
          
        test 'Multiple child text nodes should be bound', -> 
        
          complexHtml = $("<span>\#{colour}</span><table><tbody><tr class=\"\#{colour}\"><td>\#{size}</td></tr></tbody></table>")
          
          viewFirst.bindTextNodes(complexHtml, bedroom)
          
          expect(complexHtml.get(0).outerHTML + complexHtml.get(1).outerHTML).to.eql "<span>Pink</span><table><tbody><tr class=\"Pink\"><td>4</td></tr></tbody></table>"
        
      suite 'Input Binding', ->
      
        test 'An input should be bound when it has a data-property attribute', ->
        
          inputHtml = $("<input type=\"text\" data-property=\"colour\" />")
          
          viewFirst.bindInputs(inputHtml, bedroom)
          
          expect(inputHtml.val()).to.eql "Pink"
          
          inputHtml.val("Blue")
          expect(bedroom.get("colour")).to.eql "Pink"
          inputHtml.blur()
          expect(bedroom.get("colour")).to.eql "Blue"
          
          inputHtml.val("Brown")
          e = $.Event("keypress")
          e.keyCode = 13
          expect(bedroom.get("colour")).to.eql "Blue"
          inputHtml.trigger(e)
          
          expect(bedroom.get("colour")).to.eql "Brown"
          
        test 'Multiple child inputs should be bound', ->
        
          complexHtml = $("<input type=\"text\" data-property=\"colour\" /><span><input id=\"colour-input\" type=\"password\" data-property=\"size\" /></span>")
          
          viewFirst.bindInputs(complexHtml, bedroom)
          
          sizeInput = complexHtml.find("#colour-input")
          
          expect(complexHtml.val()).to.eql "Pink"
          expect(sizeInput.val()).to.eql "4"
          
          complexHtml.val("Green")
          sizeInput.val("82")
          
          complexHtml.blur()
          sizeInput.blur()
          
          expect(complexHtml.val()).to.eql "Green"
          expect(sizeInput.val()).to.eql "82"

      suite 'Collection Binding', ->

        parentNode = {}
        
        setup ->
        
          parentNode = $("<ul></ul>")
          nodeConstructionFunction = -> $("<li>\#{colour}</li>")
          viewFirst.bindCollection(Room.createCollection(), parentNode, nodeConstructionFunction)
      
        test 'A collection is bound to a simple html model', ->
        
          expect(parentNode.get(0).outerHTML).to.eql "<ul><li>White</li><li>Pink</li></ul>"

        test 'When I add an element to a collection that is reflected in the bound model', ->

          diningRoom = new Room()
          diningRoom.set("colour", "Black")
          
          expect(parentNode.get(0).outerHTML).to.eql "<ul><li>White</li><li>Pink</li><li>Black</li></ul>"
                 
        

        test 'When I remove an element from a collection that is reflected in the bound html', ->
        
        
    
    mocha.run()  