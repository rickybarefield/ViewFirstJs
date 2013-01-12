package com.appagility.viewfirstjs.test;

import java.util.List;

import junit.framework.AssertionFailedError;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import com.technophobia.substeps.model.SubSteps.Step;
import com.technophobia.substeps.model.SubSteps.StepImplementations;
import com.technophobia.webdriver.substeps.impl.AbstractWebDriverSubStepImplementations;

@StepImplementations
public class TodoSteps extends AbstractWebDriverSubStepImplementations
{

	@Step("And I delete all the todos")
	public void deleteAllTodos()
	{
		final List<WebElement> webElements = getAllDeleteButtons();
        
        for(WebElement webElement : webElements)
        {
        	webElement.click();
        }
        
        int amountOfTodoButtonsAfterDeletions = getAllDeleteButtons().size();
		if(amountOfTodoButtonsAfterDeletions > 0)
        {
        	throw new AssertionFailedError("Failed to delete all todos, pressed all the buttons but there are still " + amountOfTodoButtonsAfterDeletions);
        }
	}

	private List<WebElement> getAllDeleteButtons() {
		String deleteButtonXPath = "//button[@class=\"deleteTodoButton\"]";
		
        final List<WebElement> webElements = webDriver().findElements(By.xpath(deleteButtonXPath));
		return webElements;
	}

}
