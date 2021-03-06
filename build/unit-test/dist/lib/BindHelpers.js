// Generated by CoffeeScript 1.3.3
(function() {
  var BindHelpers, _;

  _ = require("./underscore-dep");

  module.exports = BindHelpers = (function() {

    function BindHelpers() {}

    BindHelpers.TEXT_NODE = 3;

    BindHelpers.ATTR_NODE = 2;

    BindHelpers.prototype.bindTextNodes = function(nodes, model) {
      var bindTextNode, isBindable;
      isBindable = function(node) {
        var nodeType;
        nodeType = node.get(0).nodeType;
        return (nodeType === BindHelpers.TEXT_NODE || nodeType === BindHelpers.ATTR_NODE) && (node.get(0).nodeValue.match(/#{.*}/) != null);
      };
      bindTextNode = function(node) {
        var key, keys, match, originalText, properties, property, removeSurround, replaceKeysInText, replaceOperation, _i, _j, _len, _len1, _ref;
        replaceKeysInText = function(node, originalText, keys, properties) {
          var key, pairs, property, text, _i, _len, _ref;
          pairs = _.zip(keys, properties);
          text = originalText;
          for (_i = 0, _len = pairs.length; _i < _len; _i++) {
            _ref = pairs[_i], key = _ref[0], property = _ref[1];
            text = text.replace(new RegExp("#\{" + key + "\}", 'g'), property.toString());
          }
          return node.get(0).nodeValue = text;
        };
        originalText = node.get(0).nodeValue;
        keys = [];
        properties = [];
        removeSurround = function(str) {
          return str.match(/[^#{}]+/)[0];
        };
        _ref = originalText.match(/#\{[^\}]*\}/g);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          match = _ref[_i];
          key = removeSurround(match);
          property = model.findProperty(key);
          if (property != null) {
            keys.push(key);
            properties.push(model.findProperty(key));
          }
        }
        replaceOperation = function() {
          return replaceKeysInText(node, originalText, keys, properties);
        };
        for (_j = 0, _len1 = properties.length; _j < _len1; _j++) {
          property = properties[_j];
          property.on("change", replaceOperation);
        }
        return replaceOperation();
      };
      return BindHelpers.doForNodeAndChildren(nodes, bindTextNode, isBindable);
    };

    BindHelpers.prototype.bindInputs = function(nodes, model, namedCollections) {
      var bindInput, isBindable,
        _this = this;
      isBindable = function(node) {
        return node.attr("data-property") != null;
      };
      bindInput = function(node) {
        var bindOptions, bindSimpleInput, collectionName, field, key, property;
        key = node.attr("data-property");
        field = node.attr("data-field");
        property = model.findProperty(key);
        collectionName = node.attr("data-collection");
        bindSimpleInput = function() {
          var get, set,
            _this = this;
          get = function() {
            if (field != null) {
              return property.getField(field);
            } else {
              return property.toString();
            }
          };
          set = function() {
            if (field != null) {
              return property.setField(field, node.val());
            } else {
              return property.set(node.val());
            }
          };
          node.val(get());
          node.off("keypress.viewFirst");
          node.off("blur.viewFirst");
          node.on("keypress.viewFirst", function(e) {
            if ((e.keyCode || e.which) === 13) {
              return set();
            }
          });
          return node.on("blur.viewFirst", function() {
            return set();
          });
        };
        bindOptions = function() {
          var collection, optionTemplate;
          collection = namedCollections[collectionName];
          if (collection == null) {
            throw "Unable to find collection when binding node values of select element, failed to find " + property;
          }
          optionTemplate = node.children("option");
          if (!optionTemplate) {
            throw "Unable to find option template under " + node;
          }
          optionTemplate.detach();
          this.bindCollection(collection, node, function(modelInCollection) {
            var optionNode;
            optionNode = optionTemplate.clone();
            if (property === modelInCollection) {
              optionNode.attr('selected', 'selected');
            }
            optionNode.get(0)["relatedModel"] = modelInCollection;
            node.change();
            return optionNode;
          });
          node.off("change.viewFirst");
          node.on("change.viewFirst", function() {
            var selectedOption;
            selectedOption = $(this).find("option:selected").get(0);
            if (selectedOption != null) {
              return property.set(selectedOption["relatedModel"]);
            } else {
              return property.set(null);
            }
          });
          return node.change();
        };
        if (collectionName != null) {
          return bindOptions.call(_this);
        } else {
          return bindSimpleInput();
        }
      };
      return BindHelpers.doForNodeAndChildren(nodes, bindInput, isBindable);
    };

    BindHelpers.prototype.bindCollection = function(collection, parentNode, modelToNodeFunction) {
      var addChild, boundNodes, model, _i, _len, _ref,
        _this = this;
      boundNodes = {};
      addChild = function(model) {
        var node;
        node = modelToNodeFunction(model);
        _this.bindTextNodes(node, model);
        _this.bindInputs(node, model);
        parentNode.append(node);
        return boundNodes[model.clientId] = node;
      };
      _ref = collection.getAll();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        addChild(model);
      }
      collection.on("add", addChild);
      return collection.on("remove", function(model) {
        return boundNodes[model.clientId].detach();
      });
    };

    BindHelpers.doForNodeAndChildren = function(node, func, filter) {
      var $attribute, attribute, attributes, childNode, _i, _j, _len, _len1, _ref, _results;
      if (filter == null) {
        filter = function() {
          return true;
        };
      }
      if (filter(node)) {
        func(node);
      }
      attributes = node.get(0).attributes;
      if (attributes != null) {
        for (_i = 0, _len = attributes.length; _i < _len; _i++) {
          attribute = attributes[_i];
          $attribute = $(attribute);
          if (filter($attribute)) {
            func($attribute);
          }
        }
      }
      _ref = node.contents();
      _results = [];
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        childNode = _ref[_j];
        _results.push(BindHelpers.doForNodeAndChildren($(childNode), func, filter));
      }
      return _results;
    };

    return BindHelpers;

  })();

}).call(this);
