define ["mocha", "ViewFirstTests"],
 (mocha, ViewFirstTests) ->

  mocha.setup({ ui: 'tdd', globals: ['toString', 'getInterface']})
  assert = new expect.Assertion

  suite 'ViewFirst Tests', ->
