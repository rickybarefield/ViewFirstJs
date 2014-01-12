// Generated by CoffeeScript 1.3.3
(function() {
  var ViewFirst, assert, expect, sinon;

  expect = require("./expect.js");

  sinon = require("sinon");

  assert = new expect.Assertion;

  ViewFirst = require("ViewFirstJs");

  require("./House");

  suite('ViewFirst Tests', function() {
    suite('Construction', function() {
      var snippetsContain;
      test('The correct sync dependencies should be added', function() {
        var vf1House, vf2House, viewFirst, viewFirst2;
        viewFirst = new ViewFirst("ws://address/of/websocket");
        viewFirst2 = new ViewFirst("ws://other/address/of/websocket");
        vf1House = new viewFirst.House();
        vf2House = new viewFirst2.House();
        expect(vf1House.sync.url).to.equal("ws://address/of/websocket");
        return expect(vf2House.sync.url).to.equal("ws://other/address/of/websocket");
      });
      snippetsContain = function(snippetName) {
        return expect(new ViewFirst("").snippets).to.have.key(snippetName);
      };
      test('Surround templating snippets is added', function() {
        return snippetsContain("surround");
      });
      return test('Embed templating snippets is added', function() {
        return snippetsContain("embed");
      });
    });
    return suite('Initialization', function() {
      var callbackFunc, connectCalled, mockSync, passedArg, viewFirst;
      test('Connect is called and callback is passed', function() {});
      viewFirst = new ViewFirst("ws://localhost/websocket");
      connectCalled = false;
      passedArg = null;
      mockSync = {
        connect: function(arg) {
          connectCalled = true;
          return passedArg = arg;
        }
      };
      viewFirst.sync = mockSync;
      callbackFunc = function() {};
      viewFirst.initialize(callbackFunc);
      expect(connectCalled).to.be(true);
      return expect(passedArg).to.be(callbackFunc);
    });
  });

}).call(this);