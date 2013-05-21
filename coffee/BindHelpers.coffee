define [], () ->
  class BindHelpers

    @TEXT_NODE = 3
    @ATTR_NODE = 2
  
    constructor: () ->
  
    uniqueNumber = => 
      if @lastNumber? then @lastNumber++ else @lastNumber = 1
      return @lastNumber
  
    bindCollection: (collection, parentNode, func) ->
  
      boundModels = {}
  
      addChild = (modelToAdd) =>
        console.log "adding child"
        childNode = func(modelToAdd)
        if childNode?
          @bindNodes(childNode, modelToAdd)
          @bindNodeValues(childNode, modelToAdd)
          $parent.append(childNode)
          boundModels[modelToAdd["cid"]] = childNode
  
      removeChild = (modelToRemove) ->
        childNode = boundModels[modelToRemove["cid"]]
        $(childNode).detach()
        delete boundModels[modelToRemove["cid"]]
  
      $parent = $(parentNode)
  
      context = uniqueNumber()
      console.log("context = #{context}")
  
      collection.each (model) -> addChild(model)
  
      collection.on "add", ((newModel) -> addChild(newModel)), context
      collection.on "remove", ((removedModel) -> removeChild(removedModel)), context
      collection.on "reset", ( =>
        collection.off null, null, context
        @bindCollection(collection, parentNode, func)), context
  
    bindNodeToResultOfFunction: (node, func) ->
  
      previouslyBoundModels = node.get(0)["previouslyBoundModels"]
      previouslyBoundFunction = node.get(0)["previouslyBoundFunction"]
  
      affectingModels = func()
  
      (previouslyBoundModel.off("change", currentlyBoundFunction) for previouslyBoundModel in previouslyBoundModels) if  previouslyBoundModels?
      affectingModel.on("change", func) for affectingModel in affectingModels
  
      node.get(0)["previouslyBoundModels"] = affectingModels
      node.get(0)["previouslyBoundFunction"] = func
  	
    bindNodes: (node, model) ->
  
      BindHelpers.doForNodeAndChildren node, (node) =>
  
        getReplacementTextAndAffecingModels = (nodeText, model) ->
          removeSurround = (str) ->
            str.match(/[^#{}]+/)[0]
          affectingModels = []
          replacementText = nodeText.replace /#\{[^\}]*\}/g, (match) ->
            key = removeSurround(match)
            elements = key.split(".")
            currentModel = model
            for element in elements
              if(currentModel?)
                affectingModels.push currentModel
                currentModel = currentModel.get(element)
            return if(currentModel?) then currentModel else ""
          return [replacementText, affectingModels]
  
        originalText = node.get(0).nodeValue
  
        doReplacement = ->
          [replacementText, affectingModels] = getReplacementTextAndAffecingModels(originalText, model)
          node.get(0).nodeValue = replacementText
          return affectingModels
  
        if (node.get(0).nodeType is BindHelpers.TEXT_NODE or node.get(0).nodeType is BindHelpers.ATTR_NODE) and originalText.match /#{.*}/
          @bindNodeToResultOfFunction(node, doReplacement)
  
    bindNodeValues: (node, model, collections = {}) ->
  
      addValidationAction = (property, action, reverseAction) ->
        validations[property] = [] unless validations[property]?
        validations[property].push([action, reverseAction])
    
      validations = {}
    
      model.on 'invalid', ->
        console.log "error detected"
        for error in model.validationError
          actions = validations[error.name]
          if actions?
            action[0]() for action in actions
            
      model.on 'valid', ->
      
        console.log "Went valid"
        for key,actions of validations    
          action[1]() for action in actions
        
      BindHelpers.doForNodeAndChildren node, (aNode) =>
        property = aNode.attr("data-property")
        if property?
        
          if aNode.is "select"
            #Select are handled differently to other inputs
            collectionName = aNode.attr("data-collection")
            collection = collections[collectionName]
            throw "Unable to find collection when binding node values of select element, failed to find #{property}" unless collection?
            optionTemplate = aNode.children("option")
            optionTemplate.detach()
            
            modelProperty = model.get(property)
            
            @bindCollection collection, aNode, (modelInCollection) ->
              optionNode = optionTemplate.clone()
              if modelProperty == modelInCollection
                optionNode.attr('selected', 'selected')
              optionNode.get(0)["relatedModel"] = modelInCollection
              aNode.change()
              return optionNode
            aNode.off("change.viewFirst")
            aNode.on("change.viewFirst", ->
              selectedOption = $(@).find("option:selected").get(0)
              if selectedOption?
                model.set(property, selectedOption["relatedModel"])
              else
                model.set(property, null))
            aNode.change()
            
          else    
            @bindNodeToResultOfFunction aNode, =>
              aNode.val(model.get(property))
              return model
  
            validationClass = aNode.attr("data-invalid-class")
            if validationClass?
              addValidationAction property, (-> aNode.addClass validationClass ), (-> aNode.removeClass validationClass)
            
  
            aNode.off("keypress.viewFirst")
            aNode.on("keypress.viewFirst", (e) ->
              if ((e.keyCode || e.which) == 13)
                model.set(property, aNode.val(), {validate: true})
                model.save() unless model.isNew())
  
            aNode.off("blur.viewFirst")
            aNode.on("blur.viewFirst", =>
              model.set(property, aNode.val(), {validate: true})
              model.save() unless model.isNew())
  
            aNode.val(model.get(property))
  
    @doForNodeAndChildren: (node, func) ->
  
  	#Apply to node
      func(node)
  
  	#Apply to attributes    
      attributes = node.get(0).attributes
      if attributes?
        func($(attribute)) for attribute in attributes
      
      #Apply to children
      for childNode in node.contents()
        BindHelpers.doForNodeAndChildren $(childNode), func
  
