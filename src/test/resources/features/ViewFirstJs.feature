Feature: Todos

Scenario: Adding a todo
          Given I go to the ViewFirstJs example
          And I delete all the todos
          And I type "MyTodo" into the text box
          And I click return
          Then a todo should be added with the name "MyTodo"

