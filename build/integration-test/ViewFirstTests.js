// Generated by CoffeeScript 1.3.3
(function() {
  var aHouse, assert, bedroom, cloneWithId, createHouse, expect, expectedBedroomJson, expectedHouseJson, expectedKitchenJson, expectedPostmanJson, fred, kitchen, viewFirst;

  expect = require("./expect.js");

  assert = new expect.Assertion;

  viewFirst = null;

  aHouse = {};

  kitchen = {};

  bedroom = {};

  fred = {};

  expectedKitchenJson = {};

  expectedBedroomJson = {};

  expectedPostmanJson = {};

  expectedHouseJson = {};

  createHouse = function() {
    aHouse = new viewFirst.House();
    kitchen = new viewFirst.Room();
    bedroom = new viewFirst.Room();
    fred = new viewFirst.Postman();
    fred.set("name", "Fred");
    fred.set("id", 99);
    fred.set("dob", new Date(2013, 1, 1));
    bedroom.set("colour", "Pink");
    bedroom.set("size", 4);
    kitchen.set("colour", "White");
    kitchen.set("size", 12);
    aHouse.set("doorNumber", 23);
    aHouse.set("postman", fred);
    aHouse.add("rooms", bedroom);
    aHouse.add("rooms", kitchen);
    expectedKitchenJson = {
      "colour": "White",
      "size": 12
    };
    expectedBedroomJson = {
      "colour": "Pink",
      "size": 4
    };
    expectedPostmanJson = {
      "id": 99
    };
    return expectedHouseJson = {
      "doorNumber": 23,
      "postman": expectedPostmanJson,
      "rooms": [expectedBedroomJson, expectedKitchenJson]
    };
  };

  cloneWithId = function(obj, idToAdd) {
    return $.extend(true, {
      id: idToAdd
    }, obj);
  };

  suite('ViewFirst Tests', function() {
    var requests;
    requests = null;
    setup(function() {
      viewFirst = new ViewFirst("ws://address/of/websocket");
      House.instances = [];
      House.instancesById = {};
      Room.instances = [];
      Room.instancesById = {};
      Postman.instances = [];
      Postman.instancesById = {};
      createHouse();
      viewFirst._target = "#testDiv";
      $('#testDiv').html("");
      return viewFirst.initialize("basicView");
    });
    teardown(function() {
      return viewFirst.destroy();
    });
    suite('Collections', function() {
      suite('Server Synchronised Collections', function() {
        var createResponseObject;
        createResponseObject = function(body) {
          var response;
          return response = {
            responseBody: body
          };
        };
        test('Creating a collection with no specific url will default to the models url', function() {
          var houseCollection;
          houseCollection = House.createCollection();
          return expect(houseCollection.url).to.equal("/houses");
        });
        test('Calling activate will create a subscription with the server', function() {
          var houseCollection, request;
          houseCollection = House.createCollection();
          houseCollection.activate();
          request = AtmosphereMock.lastSubscribe;
          expect(request.url).to.equal("/houses");
          expect(request.contentType).to.equal("application/json");
          return expect(request.transport).to.equal("websocket");
        });
        test('When the server returns json, the models are created within the collection', function() {
          var request, roomCollection;
          roomCollection = Room.createCollection();
          roomCollection.activate();
          request = AtmosphereMock.lastSubscribe;
          request.onMessage(createResponseObject('{"id":92, "colour":"Orange", "size":12}'));
          return expect(roomCollection.getAll().length).to.equal(1);
        });
        test('When models are added to the collection they are also added to the model class', function() {
          var request, roomCollection;
          roomCollection = Room.createCollection();
          roomCollection.activate();
          request = AtmosphereMock.lastSubscribe;
          request.onMessage(createResponseObject('{"id":92, "colour":"Orange", "size":12}'));
          return expect(Room.instancesById[92].get("colour")).to.equal("Orange");
        });
        test('Models added to the collection which are already contained in the model class are updated but two models with the same id are not created', function() {
          var request, roomCollection;
          kitchen.set("id", 101);
          roomCollection = Room.createCollection();
          roomCollection.activate();
          request = AtmosphereMock.lastSubscribe;
          request.onMessage(createResponseObject('{"id":101, "colour":"Purple", "size":65}'));
          return expect(kitchen.get("colour")).to.equal("Purple");
        });
        test('When a model is added to a collection the \'add\' event is fired', function() {
          var addCalled, roomCollection;
          addCalled = false;
          kitchen.set("id", 101);
          roomCollection = Room.createCollection();
          roomCollection.on("add", function() {
            return addCalled = true;
          });
          roomCollection.add(kitchen);
          return expect(addCalled).to.equal(true);
        });
        return test('When a model is added to a collection where it already exists no event is fired', function() {
          var addCalled, roomCollection;
          roomCollection = Room.createCollection();
          roomCollection.add(kitchen);
          addCalled = false;
          roomCollection.on("add", function() {
            return addCalled = true;
          });
          roomCollection.add(kitchen);
          return expect(addCalled).to.equal(false);
        });
      });
      return suite('Client filtered collections tests', function() {
        var houses, isEvenDoorNumber;
        houses = null;
        setup(function() {
          return houses = House.createCollection();
        });
        isEvenDoorNumber = function(house) {
          var doorNumber;
          doorNumber = house.get("doorNumber");
          return (doorNumber != null) && doorNumber % 2 === 0;
        };
        test('A filtered collection will contain matching elements when first created', function() {
          houses.add(aHouse);
          expect(houses.filter(isEvenDoorNumber).size()).to.equal(0);
          aHouse.set("doorNumber", 2);
          return expect(houses.filter(isEvenDoorNumber).size()).to.equal(1);
        });
        test('When new models are added to the server synchronised collection these are added to filtered collections if they match', function() {
          var evenHouses;
          evenHouses = houses.filter(isEvenDoorNumber);
          expect(evenHouses.size()).to.equal(0);
          aHouse.set("doorNumber", 4);
          houses.add(aHouse);
          return expect(evenHouses.size()).to.equal(1);
        });
        test('When a model changes it is added to matching filtered collections', function() {
          var anotherHouse, housesWithEvenDoorNumbers;
          houses.add(aHouse);
          housesWithEvenDoorNumbers = houses.filter(isEvenDoorNumber);
          expect(housesWithEvenDoorNumbers.size()).to.equal(0);
          anotherHouse = new House();
          houses.add(anotherHouse);
          expect(housesWithEvenDoorNumbers.size()).to.equal(0);
          anotherHouse.set("doorNumber", 2);
          expect(housesWithEvenDoorNumbers.size()).to.equal(1);
          aHouse.set("doorNumber", 4);
          return expect(housesWithEvenDoorNumbers.size()).to.equal(2);
        });
        test('When a model changes it is removed from filtered collections it no longer matches', function() {
          var evenHouses;
          aHouse.set("doorNumber", 4);
          evenHouses = houses.filter(isEvenDoorNumber);
          houses.add(aHouse);
          expect(evenHouses.size()).to.equal(1);
          aHouse.set("doorNumber", 3);
          return expect(evenHouses.size()).to.equal(0);
        });
        test('Deactivating a collection will remove it from the server collections list', function() {
          var evenHouses;
          evenHouses = houses.filter(isEvenDoorNumber);
          expect(houses.filteredCollections.length).to.equal(1);
          evenHouses.deactivate();
          return expect(houses.filteredCollections.length).to.equal(0);
        });
        return test('A collection of filtered collections can be deactivated in one go', function() {
          var evenHouses, oddHouses;
          evenHouses = houses.filter(isEvenDoorNumber);
          oddHouses = houses.filter(function() {
            return !isEvenDoorNumber;
          });
          expect(houses.filteredCollections.length).to.equal(2);
          houses.removeFilteredCollection([evenHouses, oddHouses]);
          expect(houses.filteredCollections.length).to.equal(0);
          evenHouses = houses.filter(isEvenDoorNumber);
          oddHouses = houses.filter(function() {
            return !isEvenDoorNumber;
          });
          expect(houses.filteredCollections.length).to.equal(2);
          houses.removeFilteredCollection(evenHouses, oddHouses);
          return expect(houses.filteredCollections.length).to.equal(0);
        });
      });
    });
    suite('Named Model Tests', function() {
      var hasBeenNotified, newModel, oldModel, testNotify;
      hasBeenNotified = false;
      oldModel = void 0;
      newModel = void 0;
      testNotify = function(givenOldModel, givenNewModel) {
        hasBeenNotified = true;
        oldModel = givenOldModel;
        return newModel = givenNewModel;
      };
      setup(function() {
        hasBeenNotified = false;
        oldModel = void 0;
        return newModel = void 0;
      });
      test('When a named model is changed listeners are notified when I register them first', function() {
        viewFirst.onNamedModelChange("someName", testNotify);
        expect(hasBeenNotified).to.equal(false);
        viewFirst.setNamedModel("someName", bedroom);
        expect(hasBeenNotified).to.equal(true);
        expect(oldModel).to.equal(void 0);
        expect(newModel).to.equal(bedroom);
        viewFirst.setNamedModel("someName", kitchen);
        expect(oldModel).to.equal(bedroom);
        return expect(newModel).to.equal(kitchen);
      });
      return test('When a named model is changed listeners are notified even if registered after the named model was initially created', function() {
        viewFirst.setNamedModel("someName", bedroom);
        viewFirst.onNamedModelChange("someName", testNotify);
        viewFirst.setNamedModel("someName", kitchen);
        expect(oldModel).to.equal(bedroom);
        return expect(newModel).to.equal(kitchen);
      });
    });
    return suite('Rendering views and snippets', function() {
      suite('Rendering views', function() {
        test('Views are found', function() {
          return expect(viewFirst.views.basicView).to.eql("Here I am");
        });
        test('Views which are not found throw an exception', function() {
          try {
            viewFirst.render("AViewWhichDoesNotExist");
            throw "No exception was thrown";
          } catch (error) {
            return expect(error).to.equal("Unable to find view: AViewWhichDoesNotExist");
          }
        });
        test('A basic view can be rendered into the _targetDiv', function() {
          viewFirst.render("basicView");
          return expect($('#testDiv').html()).to.eql("Here I am");
        });
        return test('Views can be changed', function() {
          viewFirst.render("basicView");
          viewFirst.render("anotherBasicView");
          return expect($('#testDiv').html()).to.eql("Here I am again!");
        });
      });
      suite('The application of snippets', function() {
        test('A simple snippet is invoked', function() {
          viewFirst.addSnippet("aSnippet", function(node) {
            node.html("A Snippet was invoked");
            return node;
          });
          viewFirst.render("viewWithSnippet");
          return expect($('#divWithASnippet').html()).to.eql("A Snippet was invoked");
        });
        test('A node will be replaced if a snippet returns a different node', function() {
          viewFirst.addSnippet("aSnippet", function(node) {
            return $("<h4>An H4 Node</h4>");
          });
          viewFirst.render("viewWithSnippet");
          return expect($('#testDiv').html()).to.eql("<h4>An H4 Node</h4>");
        });
        test('A node should be removed if a snippet returns null', function() {
          viewFirst.addSnippet("aSnippet", function(node) {
            return null;
          });
          viewFirst.render("viewWithSnippet");
          return expect($('#testDiv').html()).to.eql("");
        });
        test('Snippets are invoked from the outside in', function() {
          var increaseXAndAddToNode, x;
          x = 0;
          increaseXAndAddToNode = function(node) {
            x++;
            node.attr("someAttr", x);
            return node;
          };
          viewFirst.addSnippet("aSnippet", increaseXAndAddToNode);
          viewFirst.render("nestedSnippetsView");
          expect($('#testDiv #outerDiv').attr("someAttr")).to.eql("1");
          return expect($('#testDiv #innerDiv').attr("someAttr")).to.eql("2");
        });
        test('Snippets can return nodes which themselves invoke snippets', function() {
          var countDown, x;
          x = 11;
          countDown = function(node) {
            var nodes;
            x--;
            if (x === 0) {
              return $(document.createTextNode(x));
            } else {
              nodes = $(document.createTextNode(x));
              return nodes.add($('<div data-snippet="aSnippet"></div>'));
            }
          };
          viewFirst.addSnippet("aSnippet", countDown);
          viewFirst.render("viewWithSnippet");
          return expect($('#testDiv').html()).to.eql("109876543210");
        });
        test('Data attributes are passed', function() {
          var attributeValue;
          attributeValue = void 0;
          viewFirst.addSnippet("outerSnippet", function(node, attributes) {
            attributeValue = attributes["outer"];
            return null;
          });
          viewFirst.render("differentSnippetsView");
          return expect(attributeValue).to.equal("outer");
        });
        return test('Data attributes are passed from higher in the DOM', function() {
          var attributeValue;
          attributeValue = void 0;
          viewFirst.addSnippet("outerSnippet", function(node) {
            return node;
          });
          viewFirst.addSnippet("innerSnippet", function(node, attributes) {
            attributeValue = attributes["outer"];
            return node;
          });
          viewFirst.render("differentSnippetsView");
          return expect(attributeValue).to.equal("outer");
        });
      });
      suite('Built in snippets', function() {
        suite('Embed Snippet', function() {
          return test('A view can be embedded', function() {
            viewFirst.render("embedOfBasicView");
            return expect($('#testDiv').html()).to.eql("Before[Here I am]After");
          });
        });
        return suite('Surround Snippet', function() {
          return test('A view can be surrounded', function() {
            viewFirst.render("surroundedView");
            return expect($('#testDiv').html()).to.eql("TemplateStart[Surrounded Views Content]TemplateEnd");
          });
        });
      });
      return suite('Routing', function() {
        suite('Default', function() {
          return test('When the root url is hit the user should be taken to the view supplied in the initialize method', function() {
            expect($('#testDiv').html()).to.eql("Here I am");
            return expect(window.location.href).to.contain("basicView");
          });
        });
        suite('Named Models', function() {
          test('Setting a named model adds it to the location when it has an id', function() {
            bedroom.set("id", 5);
            viewFirst.setNamedModel("someName", bedroom);
            return expect(window.location.href).to.contain("|someName=Room!5");
          });
          test('Setting a named model does not add it to the location when it does not have an id', function() {
            viewFirst.setNamedModel("someName", bedroom);
            return expect(window.location.href).to.not.contain("Room");
          });
          test('The url is modified when a named model changes', function() {
            bedroom.set("id", 5);
            viewFirst.setNamedModel("someName", bedroom);
            expect(window.location.href).to.contain("|someName=Room!5");
            viewFirst.setNamedModel("someName", fred);
            return expect(window.location.href).to.contain("|someName=Postman!99");
          });
          test('Multiple named models can exist', function() {
            bedroom.set("id", 5);
            viewFirst.setNamedModel("someName", bedroom);
            viewFirst.setNamedModel("bestPostman", fred);
            expect(window.location.href).to.contain("|someName=Room!5");
            return expect(window.location.href).to.contain("|bestPostman=Postman!99");
          });
          test('Using the back button reverts named model changes', function() {
            bedroom.set("id", 5);
            viewFirst.setNamedModel("theRoom", bedroom);
            expect(viewFirst.getNamedModel("theRoom")).to.equal(bedroom);
            viewFirst.setNamedModel("theRoom", kitchen);
            expect(viewFirst.getNamedModel("theRoom")).to.equal(kitchen);
            history.back();
            return expect(viewFirst.getNamedModel("theRoom")).to.equal(bedroom);
          });
          return test('Entering named models in the location bar directly will set the named models', function() {});
        });
        return suite('Moving between views', function() {
          test('If a different view is selected the location is updated and the new view is displayed', function() {
            viewFirst.render("basicView");
            expect(location.hash).to.equal("#basicView");
            viewFirst.render("anotherBasicView");
            return expect(location.hash).to.equal("#anotherBasicView");
          });
          return test('If the back button is used the location bar is reverted and the previous view is displayed', function() {
            viewFirst.render("basicView");
            expect($('#testDiv').html()).to.eql("Here I am");
            viewFirst.render("anotherBasicView");
            expect($('#testDiv').html()).to.eql("Here I am again!");
            history.back();
            return expect($('#testDiv').html()).to.eql("Here I am");
          });
        });
      });
    });
  });

}).call(this);
