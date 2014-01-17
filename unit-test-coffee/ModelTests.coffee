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
