define ["jquery"], ($) ->


  ###

    This class provides the glue between ViewFirst models and the server, it could be swapped out for another implementation.  It should not have knowledge of the rest of the ViewFirst framework.

  ###

  successfulSave = (jsonString, func) ->
    func($.parseJSON(jsonString))


  AtmosphereSynchronization = 
    
    connectCollection: (url, callbackFunctions) ->

      request =
        url: url,
        contentType : "application/json",
        logLevel : 'debug',
        transport : 'websocket'

      request.onMessage = (response) ->

        message = $.parseJSON(response)

        if message.event?
          switch message.event
            when "CREATE"
              callbackFunctions['create'](message.entity)
            when "UPDATE"
              callbackFunctions['update'](message.entity)
            when "DELETE"
              callbackFunctions['delete'](message.entity)
            when "REMOVE" #No longer part of the collection
              callbackFunctions['remove'](message.entity)
            else
              console.error("Unknown event '#{message.event}', silently ignoring")
        else
          callbackFunctions['create'](message.entity)
          
      request.onError = (response) ->
        console.error("error: " + response)

      subSocket = $.atmosphere.subscribe(request)
    
    persist: (url, json, callbackFunctions) ->

      $.ajax(url, {type: 'PUT', data: json, success: (jsonString) -> successfulSave(jsonString, callbackFunctions['success'])}) 

      
    update: (url, json, callbackFunctions) ->
        
      $.ajax(url, {type: 'POST', data: json, success: (jsonString) -> successfulSave(jsonString, callbackFunctions['success'])}) 

  return AtmosphereSynchronization
