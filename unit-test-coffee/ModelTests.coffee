expect = require("./expect.js")
assert = new expect.Assertion
House = require("./House")
Room = require("./Room")
Postman = require("./Postman")

suite 'ViewFirst Model Tests', ->

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
    fred.set "dob", new Date(2013, 1, 1)
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

  setup ->
    House.instances = []
    House.instancesById = {}
    Room.instances = []
    Room.instancesById = {}
    Postman.instances = []
    Postman.instancesById = {}
    createHouse()

  suite 'Loading models', ->

    test 'A model with only simple properties can be loaded', ->

      bathroomJson = {colour: "blue", size: 6, id: 74}
      bathroom = Room.load(bathroomJson)

      expect(bathroom.get("colour")).to.equal "blue"
      expect(bathroom.get("size")).to.equal 6
      expect(bathroom.get("id")).to.equal 74

    test 'When a model is loaded which already exists, the existing model should be updated and returned', ->

      bathroomJson = {colour: "blue", size: 6, id: 74}
      bathroom = Room.load(bathroomJson)

      bathroomChangedJson = {colour: "grey", size: 6, id: 74}
      bathroomChanged = Room.load(bathroomChangedJson)

      expect(bathroomChanged).to.equal bathroom

      expect(bathroom.get("colour")).to.equal "grey"

  suite 'JSON creation', ->

    test 'The JSON from a model with only basic properties', ->

      expect(kitchen.asJson()).to.eql expectedKitchenJson

    test 'A more complex model with OneToMany and ManyToOne relationships', ->

      expect(aHouse.asJson()).to.eql expectedHouseJson


  suite 'Saving a new object', ->

    test 'Saving a model with only basic properties', ->

      kitchen.save()
      expect(requests.length).to.equal 1
      expect(requests[0].url).to.equal "/rooms"
      expect(requests[0].requestBody).to.eql JSON.stringify(expectedKitchenJson)
      expect(requests[0].method).to.equal "POST"
      requests[0].respond 201, {"Content-Type": "application/json"}, JSON.stringify(cloneWithId(expectedKitchenJson, 13))
      expect(kitchen.get("id")).to.equal 13

    test 'Saving a more complex model with OneToMany and ManyToOne relationships', ->

      #Check our test setup has not changed the original models
      expect(aHouse.get("id")).to.equal null
      expect(bedroom.get("id")).to.equal null
      expect(kitchen.get("id")).to.equal null

      aHouse.save()
      expect(requests.length).to.equal 1
      expect(requests[0].url).to.equal "/houses"
      expect(JSON.parse(requests[0].requestBody)).to.eql expectedHouseJson

      toReturn = cloneWithId(expectedHouseJson, 1)
      toReturn.rooms[0].id = 2
      toReturn.rooms[1].id = 3

      requests[0].respond 201, {"Content-Type": "application/json"}, JSON.stringify(toReturn)

      #Now check the ids have been applied
      expect(aHouse.get("id")).to.equal 1
      expect(bedroom.get("id")).to.equal 2
      expect(kitchen.get("id")).to.equal 3

    test 'Additional properties should be passed through to AJAX invocation', ->

      kitchen.save({async: false})
      expect(requests[0].async).to.equal false

  suite 'Updating and Deleting an object and persisting those changes', ->

    initiallySaveTheHouse = ->
      toReturn  = cloneWithId(expectedHouseJson, 1)
      toReturn.rooms[0].id = 2
      toReturn.rooms[1].id = 3
      aHouse.save()
      requests[0].respond 201, {"Content-Type": "application/json"}, JSON.stringify(toReturn)

    test 'Basic changed attributes are sent in a PUT request', ->

      initiallySaveTheHouse()

      #Make some changes
      aHouse.set("doorNumber", 99)

      expectedJson = {id: 1, doorNumber: 99}
      aHouse.save()
      expect(requests[1].url).to.equal "/houses/1"
      expect(requests[1].method).to.equal "PUT"
      expect(JSON.parse(requests[1].requestBody)).to.eql expectedJson

    test 'Additional properties should be passed through to AJAX invocation', ->

      kitchen.save({async: false})
      expect(requests[0].async).to.equal false

    test 'Deleting a model creates a DELETE request', ->

      initiallySaveTheHouse()

      aHouse.delete()
      expect(requests[1].url).to.equal "/houses/1"
      expect(requests[1].method).to.equal "DELETE"

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
