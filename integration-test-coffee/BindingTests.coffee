expect = require("./expect.js")
assert = new expect.Assertion
ViewFirst = require("ViewFirstJs")
require("./House")
require("./Room")
require("./Postman")

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


suite 'Binding Tests', ->

  setup ->

    viewFirst = new ViewFirst("")
    createHouse()

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

      geoff = new viewFirst.Postman()
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
      rooms = viewFirst.Room.createCollection()
      rooms.add(kitchen)
      rooms.add(bedroom)
      nodeConstructionFunction = -> $("<li>\#{colour}</li>")
      viewFirst.bindCollection(rooms, parentNode, nodeConstructionFunction)


    test 'A collection is bound to a simple html model', ->

      expect(parentNode.get(0).outerHTML).to.eql "<ul><li>White</li><li>Pink</li></ul>"

    test 'When I add an element to a collection that is reflected in the bound model', ->

      diningRoom = new viewFirst.Room()
      diningRoom.set("colour", "Black")
      rooms.add(diningRoom)

      expect(parentNode.get(0).outerHTML).to.eql "<ul><li>White</li><li>Pink</li><li>Black</li></ul>"

    test 'When I remove an element from a collection that is reflected in the bound html', ->

       rooms.remove(kitchen)
       expect(parentNode.get(0).outerHTML).to.eql "<ul><li>Pink</li></ul>"
