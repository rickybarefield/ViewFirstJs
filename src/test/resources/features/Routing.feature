Feature: Routing

Scenario: The view defined as the index should be rendered for the root url
          When I navigate to "/routing.html"
          The routing home page should be shown
          The url should be updated to "/routing.html#routingHome"

Scenario: The view defined as the index should also be accessible with its hash url
          When I navigate to "/routing.html#routingHome"
          The routing home page should be shown
          The url should remain as "/routing.html#routingHome"
          
Scenario: Other views should be accessible via their particular hash
          When I navigate to "/routing.html#otherView"
          The other view should be shown
          The url should remain as "/routing.html#otherView"

Scenario: You should be able to programatically transition between views in a snippet using the navigate method
          When I navigate to "/routing.html#routingHome"
          And click the "Go to Other View" button
          The other view should be shown
          The url should be updated to "/routing.html#otherView"
