define ["ViewFirst"], (ViewFirst) ->

  ViewFirst.Model.extend class Postman

    @url : "/postmen"

    constructor: ->
      @createProperty("name", String)
      @createProperty("dob", Date)

    ###
    @dobToString: (dob) ->

      dobAsDate = new Date(dob)
      dobAsDate.getDate() + "/" + (dobAsDate.getMonth() + 1) + "/" + dobAsDate.getFullYear()

    @dobFromString: (dobString) ->

      dobParts = dobString.split("/")
      new Date(dobParts[2], dobParts[1] - 1, dobParts[0]).getTime()
    ###