define ["backbone"], (Backbone) ->

  class ViewFirstModel extends Backbone.Model
    
    @instances: {}
  
    constructor: (attributes) ->

      instances = this.constructor.instances

      if attributes?.id?
        if instances[attributes.id]?
          console.log "returning an existing instance"
          model = instances[attributes.id]
          Backbone.Model.apply(model, arguments)
          return model

        instances[attributes.id] = this

      Backbone.Model.apply(this, arguments)

  return ViewFirstModel