package com.appagility.viewfirstjs.test;

import java.util.List;

import org.junit.Assert;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import com.technophobia.substeps.model.SubSteps.Step;
import com.technophobia.substeps.model.SubSteps.StepImplementations;
import com.technophobia.webdriver.substeps.impl.AbstractWebDriverSubStepImplementations;

@StepImplementations
public class AssertionSteps extends AbstractWebDriverSubStepImplementations
{
	@Step("AssertElementNotPresent id=\"([^\"]*)\"")
	public void assertElementNotPresent(String id)
	{
		List<WebElement> matchingElements = webDriver().findElements(By.id(id));
		if(!matchingElements.isEmpty())
		{
			throw new AssertionError("Found unexpected element with id '" + id + "'");
		}
	}
}
