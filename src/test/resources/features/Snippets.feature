Tags: Snippets

Feature: Snippets

Scenario: A snippet should be invoked when data-snippet is set on an element
          When I navigate to "/snippets.html#simplyInvoke"
          "Was Invoked" should be shown

Scenario: Snippets should be invoked from the outside in
          When I navigate to "/snippets.html#outsideIn"
          The "outerSpan" should contain "1"
          And the "innerSpan" should contain "2"
          
Scenario: Snippets can return nodes which themselves invoke snippets
          When I navigate to "/snippets.html#snippetsMakingSnippets"
          I should see 1 to 10, in that order