class window.Router

  ###
    TODO This is currently using the hashchange event, looks like this is currently poorly supported so need
         to fallback on polling mechanism.  Perhaps a jQuery special event...
  ###

  constructor: (@viewFirst, @currentBinding = "") ->
    @enableListener()


  enableListener: () ->
    window.addEventListener("hashchange", @deserialize)


  disableListener: () ->
    window.removeEventListener("hashchange", @deserialize)


  serialize: () =>
    namedModels = @viewFirst.namedModels
    modelsSerialized = for key of namedModels when namedModels[key].id?
      do (key) ->
        "#{key}=#{namedModels[key].constructor.name}!#{namedModels[key].id}"

    @currentBinding = @viewFirst.currentView + "|" + modelsSerialized.join("&")
    window.location.hash = @currentBinding
    

  deserialize: =>
    
    if "#" + @currentBinding != window.location.hash
      @disableListener()

      @currentBinding = window.location.hash.substring(1)
      viewAndRest = @currentBinding.split("|")
      view = viewAndRest[0]

      if @viewFirst.findView(view)
        @restore(view, viewAndRest[1])

      @enableListener()


  restore: (view, modelDataString) ->

      items = modelDataString.split ("&")
      console.log items
      
      @setModelForString(item) for item in items

      @viewFirst.renderView(view)
    

  setModelForString: (string) ->
    
    if string?

      [key, data] = string.split("=")

      if key? and data?

        [className, id] = data.split("!")
      
        model = window[className].find(id)
      
        @viewFirst.setNamedModel(key, model, false)
