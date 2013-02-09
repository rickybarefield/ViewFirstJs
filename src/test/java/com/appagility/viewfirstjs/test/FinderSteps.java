package com.appagility.viewfirstjs.test;

import java.util.List;

import org.junit.Assert;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import com.technophobia.substeps.model.SubSteps.Step;
import com.technophobia.substeps.model.SubSteps.StepImplementations;
import com.technophobia.webdriver.substeps.impl.AbstractWebDriverSubStepImplementations;

@StepImplementations
public class FinderSteps extends AbstractWebDriverSubStepImplementations
{    
    /**
     * Find an element by xpath relative to the current element
     * 
     * @example FindByXpath
     * @section Location
     * 
     * @param xpath
     *            the xpath
     */
    @Step("FindByXpathFromCurrentElement ([^\"]*)")
    public void findByXpathFromCurrentElement(final String xpath) {
        final WebElement elem = webDriverContext().getCurrentElement().findElement(By.xpath(xpath));
        Assert.assertNotNull("expecting an element with xpath " + xpath, elem);
        webDriverContext().setCurrentElement(elem);
    }
    
    
}
