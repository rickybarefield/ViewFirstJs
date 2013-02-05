Tags: EmbedSnippet

Feature: EmbedSnippet

Scenario: When I use the embed snippet the specified template should be embedded
          When I navigate to "/embedSnippet.html#main"
          I should see that the outerDiv is outermost
          Within this there should be the innerDiv
          And the innerDiv should contain its original content

