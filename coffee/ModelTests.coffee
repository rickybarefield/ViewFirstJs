define ["House", "Postman", "Room"], (House, Postman, Room) ->

  fred = new Postman()
  fred.set "name", "Fred"

  bedroom = new Room()
  bedroom.set "colour", "Pink"
  bedroom.set "size", 4
  
  kitchen = new Room()
  kitchen.set "colour", "White"
  kitchen.set "size", 12

  aHouse = new House()
  aHouse.set "doorNumber", 23
  aHouse.set "postman", fred
  aHouse.add "rooms", bedroom
  aHouse.add "rooms", kitchen
  
  aHouse.save()
  
  # Because postman are a ManyTo* relationship and it is not yet persisted
  # it is persisted first
  #     POST /postmans {name: "Fred"}
  # Once that id is back the House can be persisted, rooms are a OneTo* relationship so they are
  # persisted with the model
  #     POST /houses {doorNumber: 23,
  #                   postman: {id: 34}, 
  #                   rooms: [{size: "4", colour: "Pink"}, {size: 12, colour: "White"}]}
  
  