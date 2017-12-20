Feature: Language Switcher
    As a user I want to switch language between de-lat and en-en.


# there is no way to switch languages on the iphone on the homescreen.
@ipad
Scenario: Switch language on homescreen.
  Given I am on the Home Screen
    And I switch language to "DE-LAT"

  Then I wait to see "Rumpf"

  When I switch language to "EN-EN"
  Then I wait to see "Trunk"

  Then I wait


Scenario: Switch language on image list.
  Given I am on the Home Screen
    And I touch chapter 003
    And I switch language to "DE-LAT"

  Then I wait to see "Abb. 3.31 Schultergelenk, Articulatio humeri, rechts"

  Then I switch language to "EN-EN"
  Then I wait to see "Fig. 3.31 Shoulder joint, right side"


Scenario: Switch language when viewing image.
  Given I am on image "3.34"
    And I switch language to "EN-EN"

  Then caption contains "Fig. 3.34 Shoulder joint, right side"
  
  When I switch language to "DE-LAT"
  Then caption contains "Abb. 3.34 Schultergelenk, Articulatio humeri, rechts"

  Then I wait


