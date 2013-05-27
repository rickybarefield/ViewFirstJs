define ["House", "Postman", "Room", "expect", "mocha", "JQueryTestHarness", "underscore"], (House, Postman, Room, expect, mocha, JQueryTestHarness, _) ->

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
  
  
  suite 'ViewFirst Model Tests', ->

    setup ->
      createHouse() 

    suite 'JSON creation', ->

      test 'The JSON from a model with only basic properties', ->
  
        expect(kitchen.asJson()).to.eql expectedKitchenJson
      
      test 'A more complex model with OneToMany and ManyToOne relationships', ->

        expect(aHouse.asJson()).to.eql expectedHouseJson

    suite 'Saving a new object', ->

      ajaxExpectation = (url, httpMethod, data, idToAdd) ->
        
        dataToReturn = ""
        successCallback = -> throw "Attempted to do callback but ajax was not called first"
        successThis = null
        
        ajaxMethod = (url, options) ->
          expect(url).to.equal url
          expect(options["type"]).to.equal httpMethod
          expect(options["data"]).to.eql data
          successThis = this
          successCallback = options["success"]
          
          dataToReturn = if idToAdd?
            clonedData = _.extend({}, data)
            clonedData["id"] = idToAdd
            JSON.stringify(clonedData)
          else
            JSON.stringify(data)
            
        doCallback = ->
          successCallback.call(successThis, dataToReturn, "200")
          
        return [ajaxMethod, doCallback]
    
      test 'Saving a model with only basic properties', ->

        [dummyAjaxFunc, callback] = ajaxExpectation("rooms", "POST", expectedKitchenJson, 13) 
        JQueryTestHarness.addExpectation($, "ajax", dummyAjaxFunc)
        kitchen.save()
        callback()
        expect(kitchen.get("id")).to.equal(13)
        JQueryTestHarness.assertAllExpectationsMet()

      test 'Saving a more complex model with OneToMany and ManyToOne relationships', ->

      TODO Need a way to get all the ids into the dataToReturn
      
        [dummyAjaxFunc, callback] = ajaxExpectation("rooms", "POST", expectedHouseJson, 1) 
        [dummyAjaxFunc, callback] = ajaxExpectation("rooms", "POST", expectedBedroomJson, 2) 
        
      
        aHouse.save()

    mocha.run()  