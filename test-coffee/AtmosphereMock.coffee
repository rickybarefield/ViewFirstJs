define ["jquery"], ($) ->

  AtmosphereMock =

    initialize: ->

      $.atmosphere =

          subscribe: (request) -> AtmosphereMock.lastSubscribe = request

  return AtmosphereMock