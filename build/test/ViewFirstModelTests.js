// Generated by CoffeeScript 1.4.0
(function() {
  var Property, ViewFirst, assert, expect, sinon;

  expect = require("./expect.js");

  sinon = require("sinon");

  assert = new expect.Assertion;

  ViewFirst = require("ViewFirstJs");

  require("./House");

  Property = require("./Property");

  suite('ViewFirst Model Tests', function() {
    return suite('Setting properties', function() {
      suite('Setting date properties', function() {
        var dateProp;
        dateProp = null;
        setup(function() {
          return dateProp = new Property("someName", Date);
        });
        test('Setting null', function() {
          dateProp.set(null);
          return expect(dateProp.get()).to.equal(null);
        });
        test('Setting from a date', function() {
          var date;
          date = new Date(1985, 4, 8);
          dateProp.set(date);
          return expect(dateProp.get()).to.equal(date);
        });
        test('Setting from number', function() {
          var fifthOfMarch2013, retrieved;
          fifthOfMarch2013 = new Date(2013, 2, 5).getTime();
          dateProp.set(fifthOfMarch2013);
          retrieved = dateProp.get();
          return expect(retrieved.getTime()).to.equal(fifthOfMarch2013);
        });
        test('Setting from a string', function() {
          dateProp.set("20/01/2013");
          expect(dateProp.get().getDate()).to.equal(20);
          expect(dateProp.get().getFullYear()).to.equal(2013);
          return expect(dateProp.get().getMonth()).to.equal(0);
        });
        test('Setting from a string after changing the date format', function() {
          viewFirst.dateFormat = "YYYY-MM-DD";
          dateProp.set("2017-05-17");
          expect(dateProp.get().getDate()).to.equal(17);
          expect(dateProp.get().getFullYear()).to.equal(2017);
          return expect(dateProp.get().getMonth()).to.equal(4);
        });
        return test('Converting a date to a string', function() {
          dateProp.set("20/01/2013");
          return expect(dateProp.get()._viewFirstToString()).to.equal("20/01/2013");
        });
      });
      suite('Setting number properties', function() {
        var numberProp;
        numberProp = null;
        setup(function() {
          return numberProp = new Property("someName", Number);
        });
        test('Setting null', function() {
          numberProp.set(null);
          return expect(numberProp.get()).to.equal(null);
        });
        test('Setting from a Number', function() {
          numberProp.set(34);
          return expect(numberProp.get()).to.equal(34);
        });
        test('Setting from a string', function() {
          numberProp.set("098");
          return expect(numberProp.get()).to.equal(98);
        });
        test('A number with decimal places from string', function() {
          numberProp.set("6.098");
          return expect(numberProp.get()).to.equal(6.098);
        });
        return test('Converting to a string', function() {
          numberProp.set(43);
          return expect(numberProp.get()._viewFirstToString()).to.equal("43");
        });
      });
      return suite('Setting string properties', function() {
        var stringProp;
        stringProp = null;
        setup(function() {
          return stringProp = new Property("propName", String);
        });
        test('Setting null', function() {
          stringProp.set(null);
          return expect(stringProp.get()).to.equal(null);
        });
        test('Setting', function() {
          stringProp.set("Hello");
          return expect(stringProp.get()).to.equal("Hello");
        });
        return test('Converting to a String', function() {
          stringProp.set("Hello");
          return expect(stringProp.get()._viewFirstToString()).to.equal("Hello");
        });
      });
    });
  });

}).call(this);
