module.exports = class ManyToOne
  
  addToJson: (json) ->
    if @value?
      json[@name] = {id: @value.get("id")}
    else
      json[@name] = null

  setFromJson: (json, clean) ->
    @isDirty = !clean
    if json?
      @value = @type.load(json)
    else
      @value = null

  getProperty: (name) ->
    @value.getProperty(name)