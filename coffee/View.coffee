define ["jquery"], ($) ->
  class window.View
    
    @TEXT_NODE = 3
    
    constructor: (@viewId, @element) ->
    

    getElement: () => @element
