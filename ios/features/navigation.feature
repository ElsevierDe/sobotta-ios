Feature: Navigate through sobotta
    Start with the homescreen, navigate to an example image
    and swipe.

@free
Scenario: Open 1.14
  Given I am on the Home Screen
  When I touch chapter 001
    And I open image 1.14
  Then caption contains " 1.14 "

  When I swipe to next image
  Then caption contains " 1.32 "

  When I press "back"
    And I press "home"
  Then I am on the Home Screen

  Then I wait


@free
Scenario: Use mini Gallery
  Given I am on the Home Screen
  When I touch chapter 001
    And I open image 1.14
  Given mini gallery is closed
  When I open the mini gallery
    And I touch thumbnail "thumb_chp001_044-045"
    And mini gallery is closed
  Then caption contains " 1.44 "
  Then I wait and wait
  
#  Then I swipe left
#  And I wait until I don't see "Please swipe left"
#  And take picture


#Scenario: Invalid chapter
#  Given I am on the Home Screen
#  When I touch chapter 099


