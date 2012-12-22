class window.Router

  ###
    TODO This is currently using the hashchange event, looks like this is currently poorly supported so need
         to fallback on polling mechanism.  Perhaps a jQuery special event...
  ###

  constructor: (@viewFirst, @currentBinding = "") ->
    @enableListener()
  
  enableListener: () =>
    window.addEventListener "hashchange", @deserialize

  disableListener: () =>
    window.removeEventListener "hashchange", @deserialize
    
  serialize: () =>
  
    modelsSerialized = (((key) =>
                  "#{key}=#{@viewFirst.namedModels[key].constructor.name}!#{@viewFirst.namedModels[key].id}") key for key of @viewFirst.namedModels when @viewFirst.namedModels[key].id?)
    @currentBinding = @viewFirst.currentView + "|" + modelsSerialized.join("&")
    window.location.hash = @currentBinding
    
  deserialize: =>
    
    if "#" + @currentBinding != window.location.hash
      @disableListener()

      @currentBinding = window.location.hash.substring 1
      viewAndRest = @currentBinding.split "|"
      view = viewAndRest[0]

      if(@viewFirst.findView(view))
        @restore(view, viewAndRest[1])

      @enableListener()

  restore: (view, modelDataString) =>

      items = modelDataString.split ("&")
      console.log items
      
      @setModelForString item for item in items

      @viewFirst.renderView(view)
    

  setModelForString: (string) =>
    
    if string?

      keyAndData = string.split("=")

      key = keyAndData[0]
      data = keyAndData[1]

      if key? and data?

        classNameAndId = data.split("!")
      
        model = window[classNameAndId[0]].find(classNameAndId[1])
      
        @viewFirst.setNamedModel(key, model, false)