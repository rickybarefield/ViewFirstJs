Tags: Binding

Feature: Binding

Scenario: bindTextNodes should cause hash syntax to be replaced with the properties of the model
          When I navigate to "/binding.html"
          I should see the hash syntax has been replaced with the properties from the dog model

Scenario: Once a text node is bound a change to the model should be reflected in the text node
          When I navigate to "/binding.html"
          I should see the hash syntax has been replaced with the properties from the dog model
          If I then update the name of the dog in the model
          I should see that the dogs name has changed in the bound node

Scenario: A bound input node will cause the model to be updated on blur
          When I navigate to "/binding.html"
          I should see the hash syntax has been replaced with the properties from the dog model
          If I type "blue" into the changeColour input
          Then tab off of the element
          The colour in the table should be update to blue