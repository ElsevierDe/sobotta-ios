Feature: Search for labels
    As a user I want to search
    for Gluteus maximus.


Scenario: Simple Search
  Given I am on the Home Screen
  When I press "chapters"
    And I search for "Gluteus maximus"
    And I press "Gluteus maximus"

  Then I see image cell " 4.2 "
    And I see image cell " 4.123a "

  Then I wait

