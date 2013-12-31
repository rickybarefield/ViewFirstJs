Scrud = require("Scrud")

module.exports =  class Sync

  constructor: (@url) ->

    @Scud = new Scrud(@url)

  connect: (callbackFunc) -> @Scrud.connect(callbackFunc)

  forwardJson = (successFunc) ->
    forwardingJson = (scrudMessage) -> successFunc(scrudMessage.resource)


  persist: (modelType, json, successFunc) ->

    createMessage = new @Scrud.Create(resourceType, resource)
    createMessage.send(forwardJson(successFunc))

  connectCollection: ->
    console.log(arguments)
