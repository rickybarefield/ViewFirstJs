package com.appagility.viewfirstjs.test;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import com.google.common.base.Function;
import com.google.common.base.Joiner;
import com.google.common.collect.Iterables;
import com.technophobia.substeps.model.SubSteps.Step;
import com.technophobia.substeps.model.SubSteps.StepImplementations;
import com.technophobia.webdriver.substeps.impl.AbstractWebDriverSubStepImplementations;

@StepImplementations
public class SiblingSteps extends AbstractWebDriverSubStepImplementations
{
	@Step("There should be no elements before this (.*)")
	public void checkNoPreviousSibling()
	{
		List<WebElement> precedingSiblings = webDriverContext().getCurrentElement().findElements(By.xpath("./preceding-sibling"));

		if(!precedingSiblings.isEmpty())
		{
			WebElement sibling = Iterables.getFirst(precedingSiblings, null);
			throw new AssertionError("Did not expect to find a preceding sibling but found '" + sibling.toString() + "'");
		}
	}
	
	@Step("There should be no elements after this (.*)")
	public void checkNoFollowingSibling()
	{
		List<WebElement> nextSiblings = webDriverContext().getCurrentElement().findElements(By.xpath("./following-sibling"));

		if(!nextSiblings.isEmpty())
		{
			WebElement sibling = Iterables.getFirst(nextSiblings, null);
			throw new AssertionError("Did not expect to find a next sibling but found '" + sibling + "'");
		}
	}

	@Step("FindNextSibling")
	public void findNextSibling()
	{
		XPATH DOESNT SEEM TO WORK
		WebElement nextSibling = webDriverContext().getCurrentElement().findElement(By.xpath("./following-sibling"));
		
		if(nextSibling == null)
		{
			throw new AssertionError("Failed to find next sibling");
		}

		webDriverContext().setCurrentElement(nextSibling);
	}
	
}
