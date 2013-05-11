Tags: InputBinding

Feature: InputBinding

Scenario: When inputs are bound to a model changes are reflected when an input loses focus
          When I navigate to "/inputBinding.html"
          I will see the name of the dog is Alfie
          I will see the breed of the dog is Collie
          If I change the breed to Terrier
          I will see the breed of the dog remains as Collie
          But when the input loses focus
          The breed changes to Terrier
          The name of the Dog stays as Alfie

Scenario: Nested models can be bound in option lists by providing collections to bindNodeValues
          When I navigate to "/inputBinding.html#withCollars"
          I will see the yellow collar is selected
          I will see the red collar is available
          I will see the blue collar is available
          The colour of the dogs collar is yellow
          When I choose the red collar
          The colour of the dogs collar is red
          