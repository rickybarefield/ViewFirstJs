define ["House", "Postman", "Room", "expect", "mocha", "JQueryTestHarness"], (House, Postman, Room, expect, mocha, JQueryTestHarness) ->

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
    expectedKitchenJson = {"id":null,"colour":"White","size":12}
    expectedBedroomJson = {"id":null, "colour":"Pink", "size":4}
    expectedPostmanJson = {"id":null} #ManyToOne relationships should only send the id
    expectedHouseJson = {"id":null, "doorNumber": 23, "postman": expectedPostmanJson, "rooms":[expectedBedroomJson, expectedKitchenJson]}

    suite 'JSON creation', ->

      test 'The JSON from a model with only basic properties', ->
  
        expect(kitchen.asJson()).to.eql expectedKitchenJson
      
      test 'A more complex model with OneToMany and ManyToOne relationships', ->

        expect(aHouse.asJson()).to.eql expectedHouseJson

    suite 'Saving a new object', ->
    
      test 'Saving a model with only basic properties', ->
      
        kitchen.save()

    mocha.run()  