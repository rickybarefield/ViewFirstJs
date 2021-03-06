expect = require("./expect.js")
assert = new expect.Assertion

viewFirst = null

aHouse = {}
kitchen = {}
bedroom = {}
fred = {}
expectedKitchenJson = {}
expectedBedroomJson = {}
expectedPostmanJson = {}
expectedHouseJson = {}

createHouse = ->

  #Currently always creating a House
  aHouse = new viewFirst.House()
  kitchen = new viewFirst.Room()
  bedroom = new viewFirst.Room()
  fred = new viewFirst.Postman()
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

cloneWithId = (obj, idToAdd) -> $.extend(true, {id: idToAdd}, obj)

suite 'ViewFirst Tests', ->

  requests = null

  setup ->
    viewFirst = new ViewFirst("ws://address/of/websocket")
    House.instances = []
    House.instancesById = {}
    Room.instances = []
    Room.instancesById = {}
    Postman.instances = []
    Postman.instancesById = {}
    createHouse()
    viewFirst._target = "#testDiv"
    $('#testDiv').html("")
    viewFirst.initialize("basicView")

  teardown ->

    viewFirst.destroy()

  suite 'Collections', ->

    suite 'Server Synchronised Collections', ->

      createResponseObject = (body) ->
        response =
          responseBody: body

      test 'Creating a collection with no specific url will default to the models url', ->

        houseCollection = House.createCollection()
        expect(houseCollection.url).to.equal "/houses"

      test 'Calling activate will create a subscription with the server', ->

        houseCollection = House.createCollection()
        houseCollection.activate()
        request = AtmosphereMock.lastSubscribe
        expect(request.url).to.equal "/houses"
        expect(request.contentType).to.equal "application/json"
        expect(request.transport).to.equal "websocket"

      test 'When the server returns json, the models are created within the collection', ->

        roomCollection = Room.createCollection()
        roomCollection.activate()
        request = AtmosphereMock.lastSubscribe
        request.onMessage(createResponseObject ('{"id":92, "colour":"Orange", "size":12}'))

        expect(roomCollection.getAll().length).to.equal 1

      test 'When models are added to the collection they are also added to the model class', ->

        roomCollection = Room.createCollection()
        roomCollection.activate()
        request = AtmosphereMock.lastSubscribe
        request.onMessage(createResponseObject ('{"id":92, "colour":"Orange", "size":12}'))

        expect(Room.instancesById[92].get("colour")).to.equal "Orange"

      test 'Models added to the collection which are already contained in the model class are updated but two models with the same id are not created', ->

        kitchen.set("id", 101)
        roomCollection = Room.createCollection()
        roomCollection.activate()
        request = AtmosphereMock.lastSubscribe
        request.onMessage(createResponseObject ('{"id":101, "colour":"Purple", "size":65}'))

        expect(kitchen.get("colour")).to.equal "Purple"

      test 'When a model is added to a collection the \'add\' event is fired', ->

        addCalled = false
        kitchen.set("id", 101)
        roomCollection = Room.createCollection()
        roomCollection.on("add", -> addCalled = true)
        roomCollection.add(kitchen)
        expect(addCalled).to.equal true

      test 'When a model is added to a collection where it already exists no event is fired', ->

        roomCollection = Room.createCollection()
        roomCollection.add(kitchen)
        addCalled = false
        roomCollection.on("add", -> addCalled = true)
        roomCollection.add(kitchen)
        expect(addCalled).to.equal false


    suite 'Client filtered collections tests', ->

      houses = null

      setup ->

        houses = House.createCollection()

      isEvenDoorNumber = (house) ->
        doorNumber = house.get("doorNumber")
        return doorNumber? && doorNumber % 2 == 0

      test 'A filtered collection will contain matching elements when first created', ->

        houses.add(aHouse)
        expect(houses.filter(isEvenDoorNumber).size()).to.equal 0
        aHouse.set("doorNumber", 2)
        expect(houses.filter(isEvenDoorNumber).size()).to.equal 1

      test 'When new models are added to the server synchronised collection these are added to filtered collections if they match', ->

        evenHouses = houses.filter(isEvenDoorNumber)
        expect(evenHouses.size()).to.equal 0
        aHouse.set("doorNumber", 4)
        houses.add(aHouse)
        expect(evenHouses.size()).to.equal 1


      test 'When a model changes it is added to matching filtered collections', ->

        houses.add(aHouse)
        housesWithEvenDoorNumbers = houses.filter(isEvenDoorNumber)

        expect(housesWithEvenDoorNumbers.size()).to.equal 0
        anotherHouse = new House()
        houses.add(anotherHouse)
        expect(housesWithEvenDoorNumbers.size()).to.equal 0
        anotherHouse.set("doorNumber", 2)
        expect(housesWithEvenDoorNumbers.size()).to.equal 1
        aHouse.set("doorNumber", 4)
        expect(housesWithEvenDoorNumbers.size()).to.equal 2

      test 'When a model changes it is removed from filtered collections it no longer matches', ->

        aHouse.set("doorNumber", 4)
        evenHouses = houses.filter(isEvenDoorNumber)
        houses.add(aHouse)
        expect(evenHouses.size()).to.equal 1
        aHouse.set("doorNumber", 3)
        expect(evenHouses.size()).to.equal 0

      test 'Deactivating a collection will remove it from the server collections list', ->

        evenHouses = houses.filter(isEvenDoorNumber)
        expect(houses.filteredCollections.length).to.equal 1
        evenHouses.deactivate()
        expect(houses.filteredCollections.length).to.equal 0

      test 'A collection of filtered collections can be deactivated in one go', ->

        evenHouses = houses.filter(isEvenDoorNumber)
        oddHouses = houses.filter -> !isEvenDoorNumber
        expect(houses.filteredCollections.length).to.equal 2
        houses.removeFilteredCollection([evenHouses, oddHouses])
        expect(houses.filteredCollections.length).to.equal 0
        evenHouses = houses.filter(isEvenDoorNumber)
        oddHouses = houses.filter -> !isEvenDoorNumber
        expect(houses.filteredCollections.length).to.equal 2
        houses.removeFilteredCollection(evenHouses, oddHouses)
        expect(houses.filteredCollections.length).to.equal 0

  suite 'Named Model Tests', ->

    hasBeenNotified = false
    oldModel = undefined
    newModel = undefined
    testNotify = (givenOldModel, givenNewModel) ->
      hasBeenNotified = true
      oldModel = givenOldModel
      newModel = givenNewModel

    setup ->

      hasBeenNotified = false
      oldModel = undefined
      newModel = undefined


    test 'When a named model is changed listeners are notified when I register them first', ->

      viewFirst.onNamedModelChange "someName", testNotify
      expect(hasBeenNotified).to.equal false

      viewFirst.setNamedModel("someName", bedroom)
      expect(hasBeenNotified).to.equal true
      expect(oldModel).to.equal undefined
      expect(newModel).to.equal bedroom

      viewFirst.setNamedModel("someName", kitchen)
      expect(oldModel).to.equal bedroom
      expect(newModel).to.equal kitchen

    test 'When a named model is changed listeners are notified even if registered after the named model was initially created', ->

      viewFirst.setNamedModel("someName", bedroom)
      viewFirst.onNamedModelChange "someName", testNotify
      viewFirst.setNamedModel("someName", kitchen)
      expect(oldModel).to.equal bedroom
      expect(newModel).to.equal kitchen

  suite 'Rendering views and snippets', ->

    suite 'Rendering views', ->

      test 'Views are found', ->

        expect(viewFirst.views.basicView).to.eql "Here I am"

      test 'Views which are not found throw an exception', ->

        try
          viewFirst.render("AViewWhichDoesNotExist")
          throw "No exception was thrown"
        catch error
          expect(error).to.equal "Unable to find view: AViewWhichDoesNotExist"

      test 'A basic view can be rendered into the _targetDiv', ->

        viewFirst.render("basicView")
        expect($('#testDiv').html()).to.eql "Here I am"

      test 'Views can be changed', ->

        viewFirst.render("basicView")
        viewFirst.render("anotherBasicView")
        expect($('#testDiv').html()).to.eql "Here I am again!"

    suite 'The application of snippets', ->

      test 'A simple snippet is invoked', ->

        viewFirst.addSnippet "aSnippet", (node) ->
          node.html("A Snippet was invoked")
          return node

        viewFirst.render("viewWithSnippet")

        expect($('#divWithASnippet').html()).to.eql "A Snippet was invoked"

      test 'A node will be replaced if a snippet returns a different node', ->

        viewFirst.addSnippet "aSnippet", (node) -> return $("<h4>An H4 Node</h4>")
        viewFirst.render("viewWithSnippet")
        expect($('#testDiv').html()).to.eql "<h4>An H4 Node</h4>"

      test 'A node should be removed if a snippet returns null', ->

        viewFirst.addSnippet "aSnippet", (node) -> return null
        viewFirst.render("viewWithSnippet")
        expect($('#testDiv').html()).to.eql ""

      test 'Snippets are invoked from the outside in', ->

        x = 0

        increaseXAndAddToNode = (node) ->
          x++
          node.attr("someAttr", x)
          return node

        viewFirst.addSnippet("aSnippet", increaseXAndAddToNode)
        viewFirst.render("nestedSnippetsView")

        expect($('#testDiv #outerDiv').attr("someAttr")).to.eql "1"
        expect($('#testDiv #innerDiv').attr("someAttr")).to.eql "2"

      test 'Snippets can return nodes which themselves invoke snippets', ->

        x = 11

        countDown = (node) ->
          x--
          if(x == 0)
            $(document.createTextNode(x))
          else
            nodes = $(document.createTextNode(x))
            nodes.add($('<div data-snippet="aSnippet"></div>'))


        viewFirst.addSnippet "aSnippet", countDown
        viewFirst.render("viewWithSnippet")
        expect($('#testDiv').html()).to.eql "109876543210"

      test 'Data attributes are passed', ->

        attributeValue = undefined

        viewFirst.addSnippet "outerSnippet", (node, attributes) ->

          attributeValue = attributes["outer"]
          null


        viewFirst.render("differentSnippetsView")
        expect(attributeValue).to.equal "outer"

      test 'Data attributes are passed from higher in the DOM', ->

        attributeValue = undefined

        viewFirst.addSnippet "outerSnippet", (node) -> node
        viewFirst.addSnippet "innerSnippet", (node, attributes) ->

          attributeValue = attributes["outer"]
          node

        viewFirst.render("differentSnippetsView")
        expect(attributeValue).to.equal "outer"

    suite 'Built in snippets', ->

      suite 'Embed Snippet', ->

        test 'A view can be embedded', ->

          viewFirst.render("embedOfBasicView")
          expect($('#testDiv').html()).to.eql "Before[Here I am]After"

      suite 'Surround Snippet', ->

        test 'A view can be surrounded', ->

          viewFirst.render("surroundedView")
          expect($('#testDiv').html()).to.eql "TemplateStart[Surrounded Views Content]TemplateEnd"

    suite 'Routing', ->

      suite 'Default', ->

        test 'When the root url is hit the user should be taken to the view supplied in the initialize method', ->

          expect($('#testDiv').html()).to.eql "Here I am"
          expect(window.location.href).to.contain "basicView"

      suite 'Named Models', ->

        test 'Setting a named model adds it to the location when it has an id', ->

          bedroom.set("id", 5)
          viewFirst.setNamedModel("someName", bedroom)
          expect(window.location.href).to.contain "|someName=Room!5"

        test 'Setting a named model does not add it to the location when it does not have an id', ->

          viewFirst.setNamedModel("someName", bedroom)
          expect(window.location.href).to.not.contain "Room"

        test 'The url is modified when a named model changes', ->

          bedroom.set("id", 5)
          viewFirst.setNamedModel("someName", bedroom)
          expect(window.location.href).to.contain "|someName=Room!5"
          viewFirst.setNamedModel("someName", fred)
          expect(window.location.href).to.contain "|someName=Postman!99"

        test 'Multiple named models can exist', ->

          bedroom.set("id", 5)
          viewFirst.setNamedModel("someName", bedroom)
          viewFirst.setNamedModel("bestPostman", fred)
          expect(window.location.href).to.contain "|someName=Room!5"
          expect(window.location.href).to.contain "|bestPostman=Postman!99"

        test 'Using the back button reverts named model changes', ->

          bedroom.set("id", 5)
          viewFirst.setNamedModel("theRoom", bedroom)
          expect(viewFirst.getNamedModel("theRoom")).to.equal bedroom
          viewFirst.setNamedModel("theRoom", kitchen)
          expect(viewFirst.getNamedModel("theRoom")).to.equal kitchen
          history.back()
          expect(viewFirst.getNamedModel("theRoom")).to.equal bedroom


        test 'Entering named models in the location bar directly will set the named models', ->

      suite 'Moving between views', ->

        test 'If a different view is selected the location is updated and the new view is displayed', ->

          viewFirst.render("basicView")
          expect(location.hash).to.equal "#basicView"
          viewFirst.render("anotherBasicView")
          expect(location.hash).to.equal "#anotherBasicView"


        test 'If the back button is used the location bar is reverted and the previous view is displayed', ->

          viewFirst.render("basicView")
          expect($('#testDiv').html()).to.eql "Here I am"
          viewFirst.render("anotherBasicView")
          expect($('#testDiv').html()).to.eql "Here I am again!"
          history.back()
          expect($('#testDiv').html()).to.eql "Here I am"
