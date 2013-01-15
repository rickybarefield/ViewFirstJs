package com.appagility.viewfirstjs.test;

import com.technophobia.substeps.model.SubSteps.Step;
import com.technophobia.substeps.model.SubSteps.StepImplementations;
import com.technophobia.webdriver.substeps.impl.AbstractWebDriverSubStepImplementations;

@StepImplementations
public class UrlSteps extends AbstractWebDriverSubStepImplementations
{
	@Step("AssertUrlEndsWith \"([^\"]*)\"")
	public void assertUrl(String expected)
	{
		String currentUrl = webDriver().getCurrentUrl();

		if(!currentUrl.endsWith(expected))
		{
			throw new AssertionError("Was expecting the url to end with " + expected + " but it was in fact " + currentUrl);
		}
	}
}
