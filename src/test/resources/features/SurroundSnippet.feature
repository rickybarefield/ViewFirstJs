Tags: SurroundSnippet

Feature: SurroundSnippet

Scenario: When I use the surround snippet, specifying data-with and data-at the view should be surrounded
          When I navigate to "/surroundSnippet.html#simpleSurround"
          I should see that the template-div is outermost
          Within this there is its original content
          Then where binding point was there is the original content from the simpleSurround template
          Following the binding point there should be the rest of the template-divs original content
          The invoking-div which invoked the snippet should no longer be present
          The bind-point in the template-div should also have been replaced

Scenario: It should be possible to use multiple bind points
          When I navigate to "/surroundSnippet.html#multipleBinds"
          I should see that the multi-bind-template-div is outermost
          Within this there is multi-bind-template-content-1 from the multi-bind-invoking-div
          Followed by some multi-bind-template-div content
          Then there is multi-bind-template-content-2
          Lastly there is multi-bind-template-content-3
          The multi-bind-invoking-div which invoked the snippet should no longer be present
          The bind-point-1 in the multi-bind-template-div should also have been replaced
          The bind-point-2 in the multi-bind-template-div should also have been replaced
          The bind-point-3 in the multi-bind-template-div should also have been replaced
          