define ["House", "Postman", "Room", "expect", "mocha", "JQueryTestHarness", "underscore", "jquery"],
 (House, Postman, Room, expect, mocha, JQueryTestHarness, _, $) ->

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
  
  suite 'ViewFirst Model Tests', ->

    setup ->
      createHouse() 

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
                        

    mocha.run()  