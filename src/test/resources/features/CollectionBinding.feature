Tags: CollectionBinding

Feature: CollectionBinding

Scenario: The given function should be called for each model in the collection, its result added to the given parent
          When I navigate to "/collectionBinding.html"
          I will see that Colin is a Collie who is Brown and 16 inches
          I will see that Alfie is an Alsatian who is Black and 20 inches

Scenario: When a model is added to a collection the function should be called and its result added to the given parent
          When I navigate to "/collectionBinding.html"
          I will see that Colin is a Collie who is Brown and 16 inches
          I will see that Alfie is an Alsatian who is Black and 20 inches
          I will see there is no mention of a Terrier
          If I then click the "Add Terry" button
          I will see that Terry is a Terrier who is Grey and 5 inches
                    
Scenario: When a model is removed from a collection the corresponding node should be removed from the parent
          When I navigate to "/collectionBinding.html"
          I will see that Colin is a Collie who is Brown and 16 inches
          I will see that Alfie is an Alsatian who is Black and 20 inches
          If I then click the "Remove Colin" button
          I will see there is no mention of a Collie
