Feature: Index
  As a user i want to access the index, list all figures
  rotate left and do the same.


Scenario: Open Structures
  Given I am on the Home Screen
    And I switch language to "EN-EN" on homescreen
  When I touch "chapters"
    And I touch "Index"
    And I switch index to "Structures"
  Then I wait to see "Abdominal aorta"
  Then I wait

Scenario: Open Structures in Horizontal mode.
  Given I am on the Home Screen
    And I switch language to "EN-EN" on homescreen
    And I rotate device left

  When I touch "chapters"
    And I touch "Index"
    And I switch index to "Structures"
  Then I wait to see "Abdominal aorta"
  Then I wait

