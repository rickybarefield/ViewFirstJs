Scrud = require("Scrud")

module.exports =  class Sync

  constructor: (@url) ->

    @Scrud = new Scrud(@url)

  connect: (callbackFunc) -> @Scrud.connect(callbackFunc)

  forwardJson = (successFunc) ->
    forwardingJson = (scrudMessage) -> successFunc(scrudMessage.resource)


  persist: (modelType, json, successFunc) =>

    createMessage = new @Scrud.Create(modelType.modelName, json)
    createMessage.send(forwardJson(successFunc))

  connectCollection : (collection, modelType, callbackFunctions) =>

    onSuccess = (subscriptionSuccess) ->

      for id, resource of subscriptionSuccess.resources

        callbackFunctions.create(resource)

    onCreated = (created) ->

      callbackFunctions.create(created.resource)

    subscribeMessage = new @Scrud.Subscribe(modelType, onSuccess)
    subscribeMessage.send(onSuccess, onCreated)
