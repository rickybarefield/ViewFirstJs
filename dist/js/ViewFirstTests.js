// Generated by CoffeeScript 1.4.0
(function() {

  define(["ViewFirstModel", "ViewFirst", "Property", "House", "Postman", "Room", "expect", "mocha", "sinon", "sandbox", "AtmosphereMock", "underscore", "jquery"], function(ViewFirstModel, ViewFirst, Property, House, Postman, Room, expect, mocha, sinon, sandbox, AtmosphereMock, _, $) {
    var aHouse, ajaxExpectation, assert, bedroom, cloneWithId, createHouse, expectedBedroomJson, expectedHouseJson, expectedKitchenJson, expectedPostmanJson, fred, kitchen, viewFirst;
    mocha.setup('tdd', {
      globals: ['toString', 'getInterface']
    });
    AtmosphereMock.initialize();
    viewFirst = null;
    assert = new expect.Assertion;
    aHouse = {};
    kitchen = {};
    bedroom = {};
    fred = {};
    expectedKitchenJson = {};
    expectedBedroomJson = {};
    expectedPostmanJson = {};
    expectedHouseJson = {};
    createHouse = function() {
      aHouse = new House();
      kitchen = new Room();
      bedroom = new Room();
      fred = new Postman();
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
    ajaxExpectation = function(urlExpected, httpMethod, data, jsonToReturn) {
      var ajaxMethod, dataToReturn, doCallback, successCallback, successThis;
      dataToReturn = "";
      successCallback = function() {
        throw "Attempted to do callback but ajax was not called first";
      };
      successThis = null;
      ajaxMethod = function(url, options) {
        expect(urlExpected).to.equal(url);
        expect(options["type"]).to.equal(httpMethod);
        if (data != null) {
          expect(options["data"]).to.eql(data);
        }
        successThis = this;
        return successCallback = options["success"];
      };
      doCallback = function() {
        return successCallback.call(successThis, jsonToReturn, "200");
      };
      return [ajaxMethod, doCallback];
    };
    cloneWithId = function(obj, idToAdd) {
      return $.extend(true, {
        id: idToAdd
      }, obj);
    };
    return suite('ViewFirst Tests', function() {
      var requests;
      requests = null;
      setup(function() {
        var xhr;
        requests = [];
        xhr = sinon.useFakeXMLHttpRequest();
        xhr.onCreate = function(req) {
          return requests.push(req);
        };
        viewFirst = new ViewFirst();
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
      suite('ViewFirst Model Tests', function() {
        suite('Setting properties', function() {
          suite('Setting date properties', function() {
            var dateProp;
            dateProp = null;
            setup(function() {
              return dateProp = new Property("someName", Date);
            });
            test('Setting null', function() {
              dateProp.set(null);
              return expect(dateProp.get()).to.equal(null);
            });
            test('Setting from a date', function() {
              var date;
              date = new Date(1985, 4, 8);
              dateProp.set(date);
              return expect(dateProp.get()).to.equal(date);
            });
            test('Setting from number', function() {
              var fifthOfMarch2013, retrieved;
              fifthOfMarch2013 = new Date(2013, 2, 5).getTime();
              dateProp.set(fifthOfMarch2013);
              retrieved = dateProp.get();
              return expect(retrieved.getTime()).to.equal(fifthOfMarch2013);
            });
            test('Setting from a string', function() {
              dateProp.set("20/01/2013");
              expect(dateProp.get().getDate()).to.equal(20);
              expect(dateProp.get().getFullYear()).to.equal(2013);
              return expect(dateProp.get().getMonth()).to.equal(0);
            });
            test('Setting from a string after changing the date format', function() {
              viewFirst.dateFormat = "YYYY-MM-DD";
              dateProp.set("2017-05-17");
              expect(dateProp.get().getDate()).to.equal(17);
              expect(dateProp.get().getFullYear()).to.equal(2017);
              return expect(dateProp.get().getMonth()).to.equal(4);
            });
            return test('Converting a date to a string', function() {
              dateProp.set("20/01/2013");
              return expect(dateProp.get()._viewFirstToString()).to.equal("20/01/2013");
            });
          });
          suite('Setting number properties', function() {
            var numberProp;
            numberProp = null;
            setup(function() {
              return numberProp = new Property("someName", Number);
            });
            test('Setting null', function() {
              numberProp.set(null);
              return expect(numberProp.get()).to.equal(null);
            });
            test('Setting from a Number', function() {
              numberProp.set(34);
              return expect(numberProp.get()).to.equal(34);
            });
            test('Setting from a string', function() {
              numberProp.set("098");
              return expect(numberProp.get()).to.equal(98);
            });
            test('A number with decimal places from string', function() {
              numberProp.set("6.098");
              return expect(numberProp.get()).to.equal(6.098);
            });
            return test('Converting to a string', function() {
              numberProp.set(43);
              return expect(numberProp.get()._viewFirstToString()).to.equal("43");
            });
          });
          return suite('Setting string properties', function() {
            var stringProp;
            stringProp = null;
            setup(function() {
              return stringProp = new Property("propName", String);
            });
            test('Setting null', function() {
              stringProp.set(null);
              return expect(stringProp.get()).to.equal(null);
            });
            test('Setting', function() {
              stringProp.set("Hello");
              return expect(stringProp.get()).to.equal("Hello");
            });
            return test('Converting to a String', function() {
              stringProp.set("Hello");
              return expect(stringProp.get()._viewFirstToString()).to.equal("Hello");
            });
          });
        });
        suite('Loading models', function() {
          test('A model with only simple properties can be loaded', function() {
            var bathroom, bathroomJson;
            bathroomJson = {
              colour: "blue",
              size: 6,
              id: 74
            };
            bathroom = Room.load(bathroomJson);
            expect(bathroom.get("colour")).to.equal("blue");
            expect(bathroom.get("size")).to.equal(6);
            return expect(bathroom.get("id")).to.equal(74);
          });
          return test('When a model is loaded which already exists, the existing model should be updated and returned', function() {
            var bathroom, bathroomChanged, bathroomChangedJson, bathroomJson;
            bathroomJson = {
              colour: "blue",
              size: 6,
              id: 74
            };
            bathroom = Room.load(bathroomJson);
            bathroomChangedJson = {
              colour: "grey",
              size: 6,
              id: 74
            };
            bathroomChanged = Room.load(bathroomChangedJson);
            expect(bathroomChanged).to.equal(bathroom);
            return expect(bathroom.get("colour")).to.equal("grey");
          });
        });
        suite('JSON creation', function() {
          test('The JSON from a model with only basic properties', function() {
            return expect(kitchen.asJson()).to.eql(expectedKitchenJson);
          });
          return test('A more complex model with OneToMany and ManyToOne relationships', function() {
            return expect(aHouse.asJson()).to.eql(expectedHouseJson);
          });
        });
        suite('Saving a new object', function() {
          test('Saving a model with only basic properties', function() {
            kitchen.save();
            expect(requests.length).to.equal(1);
            expect(requests[0].url).to.equal("/rooms");
            expect(requests[0].requestBody).to.eql(JSON.stringify(expectedKitchenJson));
            expect(requests[0].method).to.equal("POST");
            requests[0].respond(201, {
              "Content-Type": "application/json"
            }, JSON.stringify(cloneWithId(expectedKitchenJson, 13)));
            return expect(kitchen.get("id")).to.equal(13);
          });
          return test('Saving a more complex model with OneToMany and ManyToOne relationships', function() {
            var toReturn;
            expect(aHouse.get("id")).to.equal(null);
            expect(bedroom.get("id")).to.equal(null);
            expect(kitchen.get("id")).to.equal(null);
            aHouse.save();
            expect(requests.length).to.equal(1);
            expect(requests[0].url).to.equal("/houses");
            expect(JSON.parse(requests[0].requestBody)).to.eql(expectedHouseJson);
            toReturn = cloneWithId(expectedHouseJson, 1);
            toReturn.rooms[0].id = 2;
            toReturn.rooms[1].id = 3;
            requests[0].respond(201, {
              "Content-Type": "application/json"
            }, JSON.stringify(toReturn));
            expect(aHouse.get("id")).to.equal(1);
            expect(bedroom.get("id")).to.equal(2);
            return expect(kitchen.get("id")).to.equal(3);
          });
        });
        suite('Updating and Deleting an object and persisting those changes', function() {
          var initiallySaveTheHouse;
          initiallySaveTheHouse = function() {
            var toReturn;
            toReturn = cloneWithId(expectedHouseJson, 1);
            toReturn.rooms[0].id = 2;
            toReturn.rooms[1].id = 3;
            aHouse.save();
            return requests[0].respond(201, {
              "Content-Type": "application/json"
            }, JSON.stringify(toReturn));
          };
          test('Basic changed attributes are sent in a PUT request', function() {
            var expectedJson;
            initiallySaveTheHouse();
            aHouse.set("doorNumber", 99);
            expectedJson = {
              id: 1,
              doorNumber: 99
            };
            aHouse.save();
            expect(requests[1].url).to.equal("/houses/1");
            expect(requests[1].method).to.equal("PUT");
            return expect(JSON.parse(requests[1].requestBody)).to.eql(expectedJson);
          });
          return test('Deleting a model creates a DELETE request', function() {
            initiallySaveTheHouse();
            aHouse["delete"]();
            expect(requests[1].url).to.equal("/houses/1");
            return expect(requests[1].method).to.equal("DELETE");
          });
        });
        return suite('Events are fired by models', function() {
          return test('When a property changes a change event should be fired with the old and new value of the property', function() {
            var changeCalled;
            changeCalled = false;
            aHouse.onPropertyChange("doorNumber", function(oldValue, newValue) {
              expect(oldValue).to.equal(23);
              expect(newValue).to.equal(12);
              return changeCalled = true;
            });
            aHouse.set("postman", new Postman());
            expect(changeCalled).to.equal(false);
            aHouse.set("doorNumber", 12);
            return expect(changeCalled).to.equal(true);
          });
        });
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
          test('Calling activate will request models from the server', function() {
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
      suite('Binding Tests', function() {
        suite('Text Binding', function() {
          test('A text node should be bound using the # syntax', function() {
            var linkWithTextNode;
            linkWithTextNode = $('<a>#{doorNumber}</a>');
            viewFirst.bindTextNodes(linkWithTextNode, aHouse);
            expect(linkWithTextNode.get(0).outerHTML).to.eql("<a>23</a>");
            aHouse.set("doorNumber", 98);
            return expect(linkWithTextNode.get(0).outerHTML).to.eql("<a>98</a>");
          });
          test('A text node should be bound using the # syntax when there are two # in the same text', function() {
            var linkWithTwoBinds;
            linkWithTwoBinds = $('<a>#{colour} - #{size}</a>');
            viewFirst.bindTextNodes(linkWithTwoBinds, bedroom);
            expect(linkWithTwoBinds.get(0).outerHTML).to.eql("<a>Pink - 4</a>");
            bedroom.set("colour", "Orange");
            expect(linkWithTwoBinds.get(0).outerHTML).to.eql("<a>Orange - 4</a>");
            bedroom.set("size", 12);
            return expect(linkWithTwoBinds.get(0).outerHTML).to.eql("<a>Orange - 12</a>");
          });
          test('Attributes should be bound', function() {
            var spanWithAttribute;
            spanWithAttribute = $("<span class=\"\#{colour}\">Bedroom</span>");
            viewFirst.bindTextNodes(spanWithAttribute, bedroom);
            return expect(spanWithAttribute.get(0).outerHTML).to.eql("<span class=\"Pink\">Bedroom</span>");
          });
          test('Multiple child text nodes should be bound', function() {
            var complexHtml;
            complexHtml = $("<span>\#{colour}</span><table><tbody><tr class=\"\#{colour}\"><td>\#{size}</td></tr></tbody></table>");
            viewFirst.bindTextNodes(complexHtml, bedroom);
            return expect(complexHtml.get(0).outerHTML + complexHtml.get(1).outerHTML).to.eql("<span>Pink</span><table><tbody><tr class=\"Pink\"><td>4</td></tr></tbody></table>");
          });
          return test('conversion methods should be used when present on the model', function() {
            var geoff, postmanHtml;
            geoff = new Postman();
            geoff.set("dob", new Date(1980, 5, 2).getTime());
            postmanHtml = $("<span>\#{dob}</span>");
            viewFirst.bindTextNodes(postmanHtml, geoff);
            return expect(postmanHtml.get(0).outerHTML).to.eql("<span>02/06/1980</span>");
          });
        });
        suite('Input Binding', function() {
          test('An input should be bound when it has a data-property attribute', function() {
            var e, inputHtml;
            inputHtml = $("<input type=\"text\" data-property=\"colour\" />");
            viewFirst.bindInputs(inputHtml, bedroom);
            expect(inputHtml.val()).to.eql("Pink");
            inputHtml.val("Blue");
            expect(bedroom.get("colour")).to.eql("Pink");
            inputHtml.blur();
            expect(bedroom.get("colour")).to.eql("Blue");
            inputHtml.val("Brown");
            e = $.Event("keypress");
            e.keyCode = 13;
            expect(bedroom.get("colour")).to.eql("Blue");
            inputHtml.trigger(e);
            return expect(bedroom.get("colour")).to.eql("Brown");
          });
          test('Non string fields should be bound as their type', function() {
            var e, inputHtml;
            inputHtml = $("<input type=\"text\" data-property=\"size\" />");
            viewFirst.bindInputs(inputHtml, bedroom);
            expect(bedroom.get("size")).to.equal(4);
            expect(inputHtml.val()).to.eql("4");
            inputHtml.val("7");
            e = $.Event("keypress");
            e.keyCode = 13;
            inputHtml.trigger(e);
            return expect(bedroom.get("size")).to.equal(7);
          });
          return test('Multiple child inputs should be bound', function() {
            var complexHtml, sizeInput;
            complexHtml = $("<input type=\"text\" data-property=\"colour\" /><span><input id=\"colour-input\" type=\"password\" data-property=\"size\" /></span>");
            viewFirst.bindInputs(complexHtml, bedroom);
            sizeInput = complexHtml.find("#colour-input");
            expect(complexHtml.val()).to.eql("Pink");
            expect(sizeInput.val()).to.eql("4");
            complexHtml.val("Green");
            sizeInput.val("82");
            complexHtml.blur();
            sizeInput.blur();
            expect(complexHtml.val()).to.eql("Green");
            return expect(sizeInput.val()).to.eql("82");
          });
        });
        return suite('Collection Binding', function() {
          var nodeConstructionFunction, parentNode, rooms;
          rooms = null;
          parentNode = {};
          nodeConstructionFunction = {};
          setup(function() {
            parentNode = $("<ul></ul>");
            rooms = Room.createCollection();
            rooms.add(kitchen);
            rooms.add(bedroom);
            nodeConstructionFunction = function() {
              return $("<li>\#{colour}</li>");
            };
            return viewFirst.bindCollection(rooms, parentNode, nodeConstructionFunction);
          });
          test('A collection is bound to a simple html model', function() {
            return expect(parentNode.get(0).outerHTML).to.eql("<ul><li>White</li><li>Pink</li></ul>");
          });
          test('When I add an element to a collection that is reflected in the bound model', function() {
            var diningRoom;
            diningRoom = new Room();
            diningRoom.set("colour", "Black");
            rooms.add(diningRoom);
            return expect(parentNode.get(0).outerHTML).to.eql("<ul><li>White</li><li>Pink</li><li>Black</li></ul>");
          });
          return test('When I remove an element from a collection that is reflected in the bound html', function() {
            rooms.remove(kitchen);
            return expect(parentNode.get(0).outerHTML).to.eql("<ul><li>Pink</li></ul>");
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
      suite('Rendering views and snippets', function() {
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
      return mocha.run();
    });
  });

}).call(this);
