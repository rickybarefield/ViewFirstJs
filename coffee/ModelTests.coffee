define ["House", "Postman", "Room", "expect", "mocha", "JQueryTestHarness", "underscore"], (House, Postman, Room, expect, mocha, JQueryTestHarness, _) ->

  mocha.setup('tdd')
  
  assert = new expect.Assertion
  
  suite 'ViewFirst Model Tests', ->
 
    aHouse = new House()
    kitchen = new Room()
    bedroom = new Room()
    fred = new Postman()
    fred.set "name", "Fred"
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
    expectedPostmanJson = {"id":null} #ManyToOne relationships should only send the id
    expectedHouseJson = {"doorNumber": 23, "postman": expectedPostmanJson, "rooms":[expectedBedroomJson, expectedKitchenJson]}

    suite 'JSON creation', ->

      test 'The JSON from a model with only basic properties', ->
  
        expect(kitchen.asJson()).to.eql expectedKitchenJson
      
      test 'A more complex model with OneToMany and ManyToOne relationships', ->

        expect(aHouse.asJson()).to.eql expectedHouseJson

    suite 'Saving a new object', ->
    
      test 'Saving a model with only basic properties', ->

        successCallback = null
        successThis = null
      
        JQueryTestHarness.addExpectation($, "ajax", (url, options) ->
          expect(url).to.equal "rooms"
          expect(options["type"]).to.equal "POST"
          expect(options["data"]).to.eql expectedKitchenJson
          successThis = @
          successCallback = options["success"])
          
        kitchen.save()
        
        clonedKitchenJson = _.extend({}, expectedKitchenJson)
        clonedKitchenJson["id"] = 13
        successCallback.call(successThis, JSON.stringify(clonedKitchenJson), "200")

    mocha.run()  