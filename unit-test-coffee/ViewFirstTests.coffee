proxyquire = require("proxyquire")
expect = require("./expect.js")
sinon = require("sinon")
assert = new expect.Assertion

jqueryStub = {}
mocks =
  './jquery-dep': sinon.stub().returns({ 'each': -> })

ViewFirst = proxyquire("./ViewFirst", mocks)
proxyquire("./House", {"./ViewFirst":ViewFirst})

suite 'ViewFirst Tests', ->

  global.location = ""

  suite 'Construction', ->

    test 'The correct sync dependencies should be added', ->

      viewFirst = new ViewFirst("ws://address/of/websocket")
      viewFirst2 = new ViewFirst("ws://other/address/of/websocket")

      vf1House = viewFirst.House
      vf2House = viewFirst2.House

      expect(vf1House.sync.url).to.equal "ws://address/of/websocket"
      expect(vf2House.sync.url).to.equal "ws://other/address/of/websocket"

    snippetsContain = (snippetName) -> expect(new ViewFirst("").snippets).to.have.key(snippetName)

    test 'Surround templating snippets is added', -> snippetsContain("surround")
    test 'Embed templating snippets is added', -> snippetsContain("embed")

  suite 'Initialization', ->

    test 'Connect is called and callback is passed', ->

    viewFirst = new ViewFirst("ws://localhost/websocket")
    connectCalled = false
    passedArg = null
    mockSync =
      connect: (arg) ->
        connectCalled = true
        passedArg = arg
    viewFirst.sync = mockSync
    callbackFunc = ->
    viewFirst.initialize(callbackFunc)
    expect(connectCalled).to.be(true)
    expect(passedArg).to.be(callbackFunc)
