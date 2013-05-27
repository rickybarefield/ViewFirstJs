define ["jquery"], ($) ->

  class JQueryTestHarness

    @ajax: (url, options) ->
  
      console.log "Send to " + url + " with " + options

  $.ajax = -> JQueryTestHarness.ajax.apply(@, arguments)
  
  return JQueryTestHarness  