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
  
  
  suite 'ViewFirst Model Tests', ->

    setup ->
      createHouse() 

    suite 'JSON creation', ->

      test 'The JSON from a model with only basic properties', ->
  
        expect(kitchen.asJson()).to.eql expectedKitchenJson
      
      test 'A more complex model with OneToMany and ManyToOne relationships', ->

        expect(aHouse.asJson()).to.eql expectedHouseJson

    suite 'Saving a new object', ->

      ajaxExpectation = (url, httpMethod, data, jsonToReturn) ->
        
        dataToReturn = ""
        successCallback = -> throw "Attempted to do callback but ajax was not called first"
        successThis = null
        
        ajaxMethod = (url, options) ->
          expect(url).to.equal url
          expect(options["type"]).to.equal httpMethod
          expect(options["data"]).to.eql data
          successThis = this
          successCallback = options["success"]
                      
        doCallback = ->
          successCallback.call(successThis, jsonToReturn, "200")
          
        return [ajaxMethod, doCallback]

      cloneWithId = (obj, idToAdd) -> $.extend(true, {id: idToAdd}, obj)
    
      test 'Saving a model with only basic properties', ->

        [dummyAjaxFunc, callback] = ajaxExpectation("rooms", "POST", expectedKitchenJson, JSON.stringify(cloneWithId(expectedKitchenJson, 13)))
        JQueryTestHarness.addExpectation($, "ajax", dummyAjaxFunc)
        kitchen.save()
        callback()
        expect(kitchen.get("id")).to.equal(13)
        JQueryTestHarness.assertAllExpectationsMet()

      test 'Saving a more complex model with OneToMany and ManyToOne relationships', ->

        clonedHouseJson = cloneWithId(expectedHouseJson, 1)
        clonedHouseJson.rooms[0].id = 2
        clonedHouseJson.rooms[1].id = 3
        
        #Check our test setup has not changed the original models
        expect(aHouse.get("id")).to.equal null
        expect(bedroom.get("id")).to.equal null
        expect(kitchen.get("id")).to.equal null

        [dummyAjaxFunc, callback] = ajaxExpectation("houses", "POST", expectedHouseJson, JSON.stringify(clonedHouseJson)) 
        JQueryTestHarness.addExpectation($, "ajax", dummyAjaxFunc)

        aHouse.save()
        callback()
        
        console.log(JSON.stringify(aHouse.asJson()))

        #Now check the ids have been applied
        expect(aHouse.get("id")).to.equal 1
        expect(bedroom.get("id")).to.equal 2
        expect(kitchen.get("id")).to.equal 3
        
      

    mocha.run()  