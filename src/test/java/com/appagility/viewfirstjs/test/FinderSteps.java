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
     * Finds an element on the page with the specified tag and text
     * 
     * @example FindTagElementContainingText tag="ul" text="list item itext"
     * @section Location
     * @param tag
     *            the tag
     * @param text
     *            the text
     */
    @Step("FindTagElementWithExactText tag=\"([^\"]*)\" text=\"([^\"]*)\"")
    public void findTagElementWithExactText(final String tag, final String text) {

        webDriverContext().setCurrentElement(null);
        final List<WebElement> elementsWithTagName = webDriver().findElements(By.tagName(tag));

        WebElement matchingElement = null;
        for (final WebElement element : elementsWithTagName) {

            if (element.getText().equals(text)) {

                if (matchingElement == null) {
                    matchingElement = element;
                } else {
                    Assert.fail("expected one element with tag " + tag + " and text " + text + " but found multiple");
                }
            }
        }

        Assert.assertNotNull("expecting element with tag " + tag + " and text " + text, matchingElement);
        webDriverContext().setCurrentElement(matchingElement);
    }

}
