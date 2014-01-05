expect = require("./expect.js")
assert = new expect.Assertion
Property = require("./Property")

suite 'ViewFirst Model Tests', ->

  suite 'Setting properties', ->

    suite 'Setting date properties', ->

      dateProp = null

      setup ->

        dateProp = new Property "someName", Date

      test 'Setting null', ->

        dateProp.set(null)
        expect(dateProp.get()).to.equal null

      test 'Setting from a date', ->

        date = new Date(1985, 4, 8)
        dateProp.set(date)
        expect(dateProp.get()).to.equal date

      test 'Setting from number', ->

        fifthOfMarch2013 = new Date(2013, 2, 5).getTime()
        dateProp.set(fifthOfMarch2013)
        retrieved = dateProp.get()
        expect(retrieved.getTime()).to.equal fifthOfMarch2013

      test 'Setting from a string', ->

        dateProp.set("20/01/2013")
        expect(dateProp.get().getDate()).to.equal 20
        expect(dateProp.get().getFullYear()).to.equal 2013
        expect(dateProp.get().getMonth()).to.equal 0

      test 'Setting from a string after changing the date format', ->

        viewFirst.dateFormat = "YYYY-MM-DD"
        dateProp.set("2017-05-17")
        expect(dateProp.get().getDate()).to.equal 17
        expect(dateProp.get().getFullYear()).to.equal 2017
        expect(dateProp.get().getMonth()).to.equal 4

      test 'Converting a date to a string', ->

        dateProp.set("20/01/2013")
        expect(dateProp.get()._viewFirstToString()).to.equal "20/01/2013"

    suite 'Setting number properties', ->

      numberProp = null

      setup ->

        numberProp = new Property "someName", Number

      test 'Setting null', ->

        numberProp.set(null)
        expect(numberProp.get()).to.equal null

      test 'Setting from a Number', ->

        numberProp.set(34)
        expect(numberProp.get()).to.equal 34

      test 'Setting from a string', ->

        numberProp.set("098")
        expect(numberProp.get()).to.equal 98

      test 'A number with decimal places from string', ->

        numberProp.set("6.098")
        expect(numberProp.get()).to.equal 6.098


      test 'Converting to a string', ->

        numberProp.set(43)
        expect(numberProp.get()._viewFirstToString()).to.equal "43"

    suite 'Setting string properties', ->

      stringProp = null

      setup ->

        stringProp = new Property "propName", String

      test 'Setting null', ->

        stringProp.set(null)
        expect(stringProp.get()).to.equal null

      test 'Setting', ->

        stringProp.set("Hello")
        expect(stringProp.get()).to.equal "Hello"

      test 'Converting to a String', ->

        stringProp.set("Hello")
        expect(stringProp.get()._viewFirstToString()).to.equal "Hello"
