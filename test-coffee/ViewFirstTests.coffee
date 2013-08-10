define ["ViewFirstModel", "ViewFirst", "Property", "House", "Postman", "Room", "expect", "mocha", "sinon", "sandbox", "AtmosphereMock", "underscore", "jquery"],
 (ViewFirstModel, ViewFirst, Property, House, Postman, Room, expect, mocha, sinon, sandbox, AtmosphereMock, _, $) ->

  mocha.setup('tdd')
  AtmosphereMock.initialize()

  viewFirst = null

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

  suite 'ViewFirst Tests', ->

    setup ->
      viewFirst = new ViewFirst()
      House.instances = []
      House.instancesById = {}
      Room.instances = []
      Room.instancesById = {}
      Postman.instances = []
      Postman.instancesById = {}
      createHouse()

    suite 'ViewFirst Model Tests', ->

      suite 'Setting properties', ->

        suite 'Setting date properties', ->

          dateProp = null

          setup ->

            dateProp = new Property "someName", Date

          test 'Setting null', ->

            dateProp.set(null)
            expect(dateProp.get()).to.equal null

          test 'Setting from a date', ->

            date = new Date(1985, 4, 8)
            dateProp.set(date)
            expect(dateProp.get()).to.equal date

          test 'Setting from number', ->

            fifthOfMarch2013 = new Date(2013, 2, 5).getTime()
            dateProp.set(fifthOfMarch2013)
            retrieved = dateProp.get()
            expect(retrieved.getTime()).to.equal fifthOfMarch2013

          test 'Setting from a string', ->

            dateProp.set("20/01/2013")
            expect(dateProp.get().getDate()).to.equal 20
            expect(dateProp.get().getFullYear()).to.equal 2013
            expect(dateProp.get().getMonth()).to.equal 0

          test 'Setting from a string after changing the date format', ->

            viewFirst.dateFormat = "YYYY-MM-DD"
            dateProp.set("2017-05-17")
            expect(dateProp.get().getDate()).to.equal 17
            expect(dateProp.get().getFullYear()).to.equal 2017
            expect(dateProp.get().getMonth()).to.equal 4

          test 'Converting a date to a string', ->

            dateProp.set("20/01/2013")
            expect(dateProp.get()._viewFirstToString()).to.equal "20/01/2013"

        suite 'Setting number properties', ->

          numberProp = null

          setup ->

            numberProp = new Property "someName", Number

          test 'Setting null', ->

            numberProp.set(null)
            expect(numberProp.get()).to.equal null

          test 'Setting from a Number', ->

            numberProp.set(34)
            expect(numberProp.get()).to.equal 34

          test 'Setting from a string', ->

            numberProp.set("098")
            expect(numberProp.get()).to.equal 98

          test 'A number with decimal places from string', ->

            numberProp.set("6.098")
            expect(numberProp.get()).to.equal 6.098


          test 'Converting to a string', ->

            numberProp.set(43)
            expect(numberProp.get()._viewFirstToString()).to.equal "43"

        suite 'Setting string properties', ->

          stringProp = null

          setup ->

            stringProp = new Property "propName", String

          test 'Setting null', ->

            stringProp.set(null)
            expect(stringProp.get()).to.equal null

          test 'Setting', ->

            stringProp.set("Hello")
            expect(stringProp.get()).to.equal "Hello"

          test 'Converting to a String', ->

            stringProp.set("Hello")
            expect(stringProp.get()._viewFirstToString()).to.equal "Hello"



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

          expect(kitchen.asJson()).to.eql JSON.stringify(expectedKitchenJson)

        test 'A more complex model with OneToMany and ManyToOne relationships', ->

          expect(aHouse.asJson()).to.eql expectedHouseJson


      suite 'Saving a new object', ->

        requests = null

        setup ->

          requests = []
          xhr = sinon.useFakeXMLHttpRequest()
          xhr.onCreate = (req) -> requests.push(req)

        test 'Saving a model with only basic properties', ->

          kitchen.save()
          expect(requests.length).to.equal 1
          expect(requests[0].url).to.equal "/rooms"
          expect(requests[0].requestBody).to.eql JSON.stringify(expectedKitchenJson)
          requests[0].respond 201, {"Content-Type": "application/json"}, JSON.stringify(cloneWithId(expectedKitchenJson, 13))
          expect(kitchen.get("id")).to.equal 13

        test 'Saving a more complex model with OneToMany and ManyToOne relationships', ->

          jsonForServerToReturn = createHouseJsonReturnedOnSave()

          #Check our test setup has not changed the original models
          expect(aHouse.get("id")).to.equal null
          expect(bedroom.get("id")).to.equal null
          expect(kitchen.get("id")).to.equal null

          [dummyAjaxFunc, callback] = ajaxExpectation("houses", "POST", expectedHouseJson, JSON.stringify(jsonForServerToReturn))

          aHouse.save()
          callback()

          #Now check the ids have been applied
          expect(aHouse.get("id")).to.equal 1
          expect(bedroom.get("id")).to.equal 2
          expect(kitchen.get("id")).to.equal 3


      suite 'Updating and Deleting an object and persisting those changes', ->

        initiallySaveTheHouse = ->
          jsonForServerToReturnOnSave = createHouseJsonReturnedOnSave()
          [dummyAjaxFunc, callback] = ajaxExpectation("houses", "POST", expectedHouseJson, JSON.stringify(jsonForServerToReturnOnSave))
          aHouse.save()
          callback()

        test 'Basic changed attributes are sent in a PUT request', ->

          initiallySaveTheHouse()

          #Make some changes
          aHouse.set("doorNumber", 99)

          expectedJson = {id: 1, doorNumber: 99}
          dummyServerResponse = JSON.stringify(aHouse.asJson())
          [dummyAjaxFunc, callback] = ajaxExpectation("houses/1", "PUT", expectedJson, dummyServerResponse)
          aHouse.save()
          callback()

        test 'Deleting a model creates a DELETE request', ->

          initiallySaveTheHouse()

          [dummyAjaxFunc, callback] = ajaxExpectation("houses/1", "DELETE", null, null)
          aHouse.delete()
          callback()

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

    suite 'Collections', ->

      suite 'Server Synchronised Collections', ->

        createResponseObject = (body) ->
          response =
            responseBody: body

        test 'Creating a collection with no specific url will default to the models url', ->

          houseCollection = House.createCollection()
          expect(houseCollection.url).to.equal "/houses"

        test 'Calling activate will request models from the server', ->

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

        test 'conversion methods should be used when present on the model', ->

          geoff = new Postman()
          geoff.set("dob", new Date(1980, 5, 2).getTime())
          postmanHtml = $("<span>\#{dob}</span>")
          viewFirst.bindTextNodes(postmanHtml, geoff)
          expect(postmanHtml.get(0).outerHTML).to.eql "<span>02/06/1980</span>"

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

        test 'Non string fields should be bound as their type', ->

          inputHtml = $("<input type=\"text\" data-property=\"size\" />")

          viewFirst.bindInputs(inputHtml, bedroom)

          expect(bedroom.get("size")).to.equal 4

          expect(inputHtml.val()).to.eql "4"
          inputHtml.val("7")
          e = $.Event("keypress")
          e.keyCode = 13
          inputHtml.trigger(e)

          expect(bedroom.get("size")).to.equal 7


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

        rooms = null
        parentNode = {}
        nodeConstructionFunction = {}

        setup ->

          parentNode = $("<ul></ul>")
          rooms = Room.createCollection()
          rooms.add(kitchen)
          rooms.add(bedroom)
          nodeConstructionFunction = -> $("<li>\#{colour}</li>")
          viewFirst.bindCollection(rooms, parentNode, nodeConstructionFunction)


        test 'A collection is bound to a simple html model', ->

          expect(parentNode.get(0).outerHTML).to.eql "<ul><li>White</li><li>Pink</li></ul>"

        test 'When I add an element to a collection that is reflected in the bound model', ->

          diningRoom = new Room()
          diningRoom.set("colour", "Black")
          rooms.add(diningRoom)

          expect(parentNode.get(0).outerHTML).to.eql "<ul><li>White</li><li>Pink</li><li>Black</li></ul>"

        test 'When I remove an element from a collection that is reflected in the bound html', ->

           rooms.remove(kitchen)
           expect(parentNode.get(0).outerHTML).to.eql "<ul><li>Pink</li></ul>"

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

      setup ->

        viewFirst._target = "#testDiv"
        $('#testDiv').html("")
        viewFirst.initialize()

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



    mocha.run()
