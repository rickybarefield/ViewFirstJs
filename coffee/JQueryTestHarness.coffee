define ["expect", "jquery"], (Expect, $) ->

  class JQueryTestHarness

    @_expectations: {}

    @addExpectation: (objectToMockMethodOn, methodName, func) ->
    
      getExpectationArray = (name) ->
        expectationArray = JQueryTestHarness._expectations[name]
        expectationArray = JQueryTestHarness._expectations[name] = [] unless expectationArray
        return expectationArray
    
      expectations = getExpectationArray(methodName)
      expectations.push(func)
      objectToMockMethodOn[methodName] = -> JQueryTestHarness._mockMethod.call(@, methodName, arguments)

    @assertAllExpectationsMet: ->
      throw "Not all expectations have been met" unless $.isEmptyObject(JQueryTestHarness._expectations)


    @_mockMethod: (methodName, givenArguments) ->
    
      expectations = JQueryTestHarness._expectations[methodName]
      throw "A call on #{methodName} was not expected" unless expectations? and expectations.length > 0
      func = expectations.pop()
      if expectations.length == 0 then delete JQueryTestHarness._expectations[methodName]
      func.apply(@, givenArguments)


  return JQueryTestHarness  