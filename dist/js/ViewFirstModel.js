// Generated by CoffeeScript 1.4.0
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(["underscore", "jquery", "Property", "ViewFirstEvents", "AtmosphereSynchronization"], function(_, $, Property, Events, Sync) {
    var ClientFilteredCollection, Collection, Model, ServerSynchronisedCollection;
    Collection = (function(_super) {

      __extends(Collection, _super);

      function Collection() {
        Collection.__super__.constructor.apply(this, arguments);
        this.instances = {};
      }

      Collection.prototype.getAll = function() {
        var key, value, _ref, _results;
        _ref = this.instances;
        _results = [];
        for (key in _ref) {
          value = _ref[key];
          _results.push(value);
        }
        return _results;
      };

      Collection.prototype.size = function() {
        return Object.keys(this.instances).length;
      };

      Collection.prototype.add = function(model, silent) {
        if (silent == null) {
          silent = false;
        }
        this.instances[model.clientId] = model;
        if (!silent) {
          return this.trigger("add", model);
        }
      };

      Collection.prototype.remove = function(model) {
        delete this.instances[model.clientId];
        return this.trigger("remove", model);
      };

      return Collection;

    })(Events);
    ClientFilteredCollection = (function(_super) {

      __extends(ClientFilteredCollection, _super);

      function ClientFilteredCollection(serverSyncCollection) {
        this.serverSyncCollection = serverSyncCollection;
        this.deactivate = __bind(this.deactivate, this);

        ClientFilteredCollection.__super__.constructor.apply(this, arguments);
      }

      ClientFilteredCollection.prototype.deactivate = function() {
        return this.serverSyncCollection.removeFilteredCollection(this);
      };

      return ClientFilteredCollection;

    })(Collection);
    ServerSynchronisedCollection = (function(_super) {

      __extends(ServerSynchronisedCollection, _super);

      function ServerSynchronisedCollection(modelType, url) {
        this.modelType = modelType;
        this.url = url;
        this.activate = __bind(this.activate, this);

        this.removeFilteredCollection = __bind(this.removeFilteredCollection, this);

        this.filter = __bind(this.filter, this);

        ServerSynchronisedCollection.__super__.constructor.apply(this, arguments);
        if (!this.url) {
          this.url = modelType.url;
        }
        this.filteredCollections = [];
      }

      ServerSynchronisedCollection.prototype.filter = function(filter) {
        var filteredCollection, filteredCollectionObject, key, model, _ref;
        filteredCollection = new ClientFilteredCollection(this);
        filteredCollectionObject = {
          collection: filteredCollection,
          filter: filter
        };
        this.filteredCollections.push(filteredCollectionObject);
        _ref = this.instances;
        for (key in _ref) {
          model = _ref[key];
          if (filter(model)) {
            filteredCollection.add(model, true);
          }
        }
        return filteredCollection;
      };

      ServerSynchronisedCollection.prototype.removeFilteredCollection = function() {
        var collections;
        collections = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.filteredCollections = _.filter(this.filteredCollections, function(collObj) {
          return __indexOf.call(collections, collObj) >= 0;
        });
      };

      ServerSynchronisedCollection.prototype.add = function(model, silent) {
        var filteredCollection, _i, _len, _ref,
          _this = this;
        if (silent == null) {
          silent = false;
        }
        ServerSynchronisedCollection.__super__.add.apply(this, arguments);
        _ref = this.filteredCollections;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          filteredCollection = _ref[_i];
          if (filteredCollection.filter(model)) {
            filteredCollection.collection.add(model);
          }
        }
        return model.on("change", function() {
          var matches, _j, _len1, _ref1, _results;
          _ref1 = _this.filteredCollections;
          _results = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            filteredCollection = _ref1[_j];
            matches = filteredCollection.filter(model);
            if (matches && !(filteredCollection.collection.instances[model.clientId] != null)) {
              filteredCollection.collection.add(model, silent);
            }
            if (!matches && (filteredCollection.collection.instances[model.clientId] != null)) {
              _results.push(filteredCollection.collection.remove(model));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        });
      };

      ServerSynchronisedCollection.prototype.activate = function() {
        var callbackFunctions,
          _this = this;
        callbackFunctions = {
          create: function(json) {
            var model;
            model = _this.modelType.load(json);
            return _this.add(model);
          },
          update: function(json) {
            return _this.modelType.load(json);
          },
          "delete": function(json) {
            _this.modelType.load(json);
            throw "delete is not yet implemented";
          },
          remove: function(json) {
            var model;
            model = _this.modelType.load(json);
            return _this.remove(model);
          }
        };
        return Sync.connectCollection(this.url, callbackFunctions);
      };

      return ServerSynchronisedCollection;

    })(Collection);
    Model = (function(_super) {
      var addCreateCollectionFunction, addInstances, addLoadMethod, createClientId, ensureModelValid, lastClientIdUsed;

      __extends(Model, _super);

      Model.models = {};

      function Model() {
        this.update = __bind(this.update, this);

        var idProperty,
          _this = this;
        Model.__super__.constructor.apply(this, arguments);
        this.properties = {};
        this.clientId = createClientId();
        idProperty = this.createProperty("id", Number);
        idProperty.on("change", function(oldValue, newValue) {
          if (oldValue != null) {
            throw "Cannot set id as it has already been set";
          }
          if (_this.constructor.instancesById[newValue] != null) {
            throw "Cannot set the id to " + newValue + " as another object has that id";
          }
          return _this.constructor.instancesById[newValue] = _this;
        });
      }

      lastClientIdUsed = 0;

      createClientId = function() {
        return lastClientIdUsed = lastClientIdUsed + 1;
      };

      Model.prototype.createProperty = function(name, type, relationship) {
        var property,
          _this = this;
        property = new Property(name, type, relationship);
        property.on("change", function() {
          return _this.trigger("change");
        });
        this.properties[name] = property;
        return property;
      };

      Model.prototype.isNew = function() {
        return !(this.isPersisted());
      };

      Model.prototype.isPersisted = function() {
        return this.properties["id"].isSet();
      };

      Model.prototype.get = function(name) {
        return this.properties[name].get();
      };

      Model.prototype.getProperty = function(name) {
        return this.properties[name];
      };

      Model.prototype.findProperty = function(key) {
        var current, element, elements, _i, _len;
        elements = key.split(".");
        current = this;
        for (_i = 0, _len = elements.length; _i < _len; _i++) {
          element = elements[_i];
          current = this.getProperty(element);
        }
        return current;
      };

      Model.prototype.set = function(name, value) {
        return this.properties[name].set(value);
      };

      Model.prototype.add = function(name, value) {
        return this.properties[name].add(value);
      };

      Model.prototype.removeAll = function(name) {
        return this.properties[name].removeAll();
      };

      Model.prototype.onPropertyChange = function(propertyName, func) {
        return this.properties[propertyName].on("change", func);
      };

      Model.prototype.asJson = function(includeOnlyDirtyProperties) {
        var json, key, property, _ref;
        if (includeOnlyDirtyProperties == null) {
          includeOnlyDirtyProperties = true;
        }
        json = {};
        _ref = this.properties;
        for (key in _ref) {
          property = _ref[key];
          if (!includeOnlyDirtyProperties || property.isDirty || property.name === "id") {
            property.addToJson(json, includeOnlyDirtyProperties);
          }
        }
        return json;
      };

      Model.prototype.save = function() {
        var callbackFunctions, json, saveFunction, url;
        callbackFunctions = {
          success: this.update
        };
        saveFunction = this.isNew() ? Sync.persist : Sync.update;
        url = this.isNew() ? this.constructor.url : this.constructor.url + "/" + this.get("id");
        json = JSON.stringify(this.asJson());
        return saveFunction(url, json, callbackFunctions);
      };

      Model.prototype["delete"] = function() {
        var callbackFunctions;
        callbackFunctions = {
          success: function() {
            return console.log("TODO will need to trigger an event");
          }
        };
        return Sync["delete"](this.constructor.url + "/" + this.get("id"), callbackFunctions);
      };

      Model.prototype.update = function(json, clean) {
        var key, value, _results;
        if (clean == null) {
          clean = true;
        }
        _results = [];
        for (key in json) {
          value = json[key];
          _results.push(this.properties[key].setFromJson(value, clean = true));
        }
        return _results;
      };

      addInstances = function(Child) {
        Child.instances = [];
        return Child.instancesById = {};
      };

      addLoadMethod = function(Child) {
        return Child.load = function(json) {
          var childObject, id;
          id = json.id;
          childObject = Child.instancesById[id] != null ? Child.instancesById[id] : new Child;
          childObject.update(json);
          return childObject;
        };
      };

      addCreateCollectionFunction = function(Child) {
        return Child.createCollection = function(url) {
          return new ServerSynchronisedCollection(Child, url);
        };
      };

      ensureModelValid = function(Model) {
        if (!Model.url) {
          throw "url must be set as a static property";
        }
      };

      Model.find = function(modelType, id) {
        return this.models[modelType].instancesById[id];
      };

      Model.extend = function(Child) {
        var ChildExtended, Surrogate;
        ensureModelValid(Child);
        ChildExtended = function() {
          Model.apply(this, arguments);
          Child.apply(this, arguments);
          this.constructor.instances.push(this);
          this.constructor.trigger("created", this);
          return this;
        };
        ChildExtended.modelName = Child.name;
        this.models[Child.name] = ChildExtended;
        Surrogate = function() {};
        Surrogate.prototype = this.prototype;
        ChildExtended.prototype = new Surrogate;
        ChildExtended.prototype.constructor = ChildExtended;
        _.extend(ChildExtended, new Events);
        _.extend(ChildExtended, Child);
        _.extend(ChildExtended.prototype, Child.prototype);
        addInstances(ChildExtended);
        addLoadMethod(ChildExtended);
        addCreateCollectionFunction(ChildExtended);
        return ChildExtended;
      };

      return Model;

    })(Events);
    return Model;
  });

}).call(this);
