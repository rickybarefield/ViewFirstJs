Tags: NamedModels

# The idea of named models is that two snippets may want to operate on the same model.
# For instance, in a application maintaining tasks, one snippet may display a dropdown 
# list of tasks, whilst another shows details of the selected task. These two snippets 
# will need to interact, if they both refer to the same 'named model' this can be achieved
# since the framework can provide notifications if the named model changes.
Feature: Named Models

Scenario: Notifications should be sent if a named model is set, both the old model and the new model should be passed
          When I navigate to "/namedModel.html"
          Nothing should be shown in the "oldModelParagraph"
          Nothing should be shown in the "newModelParagraph"
          Then I click the "Set Original Model" button
          The "originalValue" should be shown in the "newModelParagraph"
          Nothing should be shown in the "oldModelParagraph"
          Then I click the "Update Model" button
          Now the "originalValue" should be shown in the "oldModelParagraph"
          And the "newValue" should be shown in the "newModelParagraph"
          
          
Scenario: Notifications should be sent if a named model becomes unset (i.e. set with null)
          When I navigate to "/namedModel.html"
          Nothing should be shown in the "oldModelParagraph"
          Nothing should be shown in the "newModelParagraph"
          Then I click the "Set Original Model" button
          Now "originalValue" should be shown in the "newModelParagraph"
          Then I click the "Clear Model" button
          The "originalValue" should be shown in the "oldModelParagraph"
          And Nothing should be shown in the "newModelParagraph"

Scenario: Named models represent the state of a page so should be reflected in the url
          When I navigate to "/namedModel.html"
          The url should not include any named models
          If I click the "Set Original Model" button
          The url should now include a named model with "aName" of type "TestModel" and id "1"
          If I click the "Update Model" button
          The url should now include a named model with "aName" of type "TestModel" and id "2"
		  If I click the "Clear Model" button
          The url should not include any named models
          
Scenario: If a url is loaded with named models included, those named models should be set and available to snippets
          When I navigate to "/namedModel.html#main/aName!TestModel!2"
          The "newValue" should be shown in the "newModelParagraph"



#TODO What would you expect to happen with transitions between pages? Should listeners be purged?