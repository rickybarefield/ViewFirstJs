_ = require("underscore")

module.exports = class BindHelpers

  @TEXT_NODE = 3
  @ATTR_NODE = 2

  bindTextNodes: (nodes, model) ->

    isBindable = (node) ->
      nodeType = node.get(0).nodeType
      return (nodeType is BindHelpers.TEXT_NODE or nodeType is BindHelpers.ATTR_NODE) and node.get(0).nodeValue.match(/#{.*}/)?

    bindTextNode =  (node) ->

      replaceKeysInText = (node, originalText, keys, properties) ->
        pairs = _.zip(keys, properties)
        text = originalText
        for [key, property] in pairs
          text = text.replace new RegExp("#\{#{key}\}", 'g'), property.toString()
        node.get(0).nodeValue = text

      originalText = node.get(0).nodeValue

      keys = []
      properties = []

      removeSurround = (str) ->
        str.match(/[^#{}]+/)[0]

      for match in originalText.match /#\{[^\}]*\}/g
        key = removeSurround(match)
        property = model.findProperty(key)
        if property?
          keys.push key
          properties.push model.findProperty(key)

      replaceOperation = -> replaceKeysInText(node, originalText, keys, properties)
      property.on("change", replaceOperation) for property in properties

      replaceOperation()

    BindHelpers.doForNodeAndChildren nodes, bindTextNode, isBindable

  bindInputs: (nodes, model, namedCollections) ->

    isBindable = (node) -> node.attr("data-property")?

    bindInput = (node) =>

      key = node.attr("data-property")
      property = model.findProperty(key)
      collectionName = node.attr("data-collection")

      bindSimpleInput = ->
        node.val(property.toString())
        node.off("keypress.viewFirst")
        node.off("blur.viewFirst")

        node.on "keypress.viewFirst", (e) ->
          if ((e.keyCode || e.which) == 13)
            property.set(node.val())
        node.on "blur.viewFirst", =>
          property.set(node.val())

      bindOptions = ->

        collection = namedCollections[collectionName]
        throw "Unable to find collection when binding node values of select element, failed to find #{property}" unless collection?
        optionTemplate = node.children("option")
        throw "Unable to find option template under #{node}" unless optionTemplate
        optionTemplate.detach()

        @bindCollection collection, node, (modelInCollection) ->
          optionNode = optionTemplate.clone()
          if property == modelInCollection
            optionNode.attr('selected', 'selected')
          optionNode.get(0)["relatedModel"] = modelInCollection
          node.change()
          return optionNode
        node.off "change.viewFirst"
        node.on "change.viewFirst", ->
          selectedOption = $(@).find("option:selected").get(0)
          if selectedOption?
            property.set(selectedOption["relatedModel"])
          else
            property.set(null)
        node.change()


      if collectionName?
        bindOptions.call(@)
      else
        bindSimpleInput()


    BindHelpers.doForNodeAndChildren nodes, bindInput, isBindable

  bindCollection: (collection, parentNode, modelToNodeFunction) ->

    boundNodes = {}

    addChild = (model) =>

      node = modelToNodeFunction(model)
      @bindTextNodes(node, model)
      @bindInputs(node, model)
      parentNode.append(node)
      boundNodes[model.clientId] = node

    addChild(model) for model in collection.getAll()

    collection.on "add", addChild
    collection.on "remove", (model) ->
      boundNodes[model.clientId].detach()

  @doForNodeAndChildren: (node, func, filter = -> true) ->

    #Apply to node
    if(filter(node))
      func(node)

    #Apply to attributes
    attributes = node.get(0).attributes
    if attributes?
      for attribute in attributes
        $attribute = $(attribute)
        if(filter($attribute))
          func($attribute)

    #Apply to children
    for childNode in node.contents()
      BindHelpers.doForNodeAndChildren $(childNode), func, filter
