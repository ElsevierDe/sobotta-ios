Feature: Training
    as a user i want to train figures.


@free
Scenario: Train simple figure
  Given I am on the Home Screen
  When I touch chapter 001
    And I open image 1.14
  Then I touch "Training"
    And I wait to see "Change Training Mode"
