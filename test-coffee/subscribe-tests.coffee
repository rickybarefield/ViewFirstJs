expect = require("./expect.js")
sinon = require("sinon")
Scrud = require("./Scrud.js")
assert = new expect.Assertion

suite 'Existing entities', ->

  test 'If there are no existing models on the server the collection size should be 0', ->

    allHouses = House.createCollection()
    allHouses.activate()
    #TODO Send success response, with no existing objects
    expect(allHouses.size()).to.equal 0

  test 'If there are existing models on the server, the collection should be populated', ->

    allHouses = House.createCollection()
    allHouses.activate()
    #TODO Send success response, with existing objects
    expect(allHouses.size()).to.equal 0
    #TODO Check the objects

  test 'Where a model on the server is returned which already exists on the client, no new object should be created', ->

    allHouses = House.createCollection()


    createHouse = ->

      house = new House()
      house.set("doorNumber", 4)
      house.save(connectCollection)
      return house

    sendCreateResponse = ->

      #TODO

    house = createHouse()
    sendCreateResponse()
    allHouses.activate()
    expect(allHouses.size()).to.equal 1
    expect(house).to.equal allHouses.getAll[0]


suite 'Created entities', ->

  test 'Entities are created', ->
    allHouses = House.createCollection()
    allHouses.activate()
    #Send response with no existing entities
    expect(allHouses.size()).to.equal 0

    #Send a created message
    expect(allHouses.size()).to.equal 1


