class A

  instancePropOfA: true
  
  @aStaticProp : true
  
  constructor: ->
    console.log "A constructed"
    
  @extend: ->
    console.log("being extended")
  
class B extends A

  constructor: ->
    console.log "B constructed"
    
    
a1 = new A()
b1 = new B()
b2 = new B()


