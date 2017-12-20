Feature: Layer
    As a user I want to change layer options.


@ipad
Scenario: Switch between important and all pins (ipad)
  Given I am on image "3.34"
    And I switch language to "EN-EN"
    And I select layer outline "Pins"

  When I select layer structures "Important"
  Then I see 7 pins

  When I select layer structures "All"
  Then I see 15 pins

  Then I select layer outline "Labels"
  Then I wait


@iphone
Scenario: Switch between important and all pins (iphone)
  # iPhone shows images smaller, so pins are partially hidden and so
  # we have to zoom in.
  Given I am on image "3.34"
    And I switch language to "EN-EN"
    And I select layer outline "Pins"

  When I select layer structures "Important"
    And I pinch to zoom image in
    And I pinch to zoom image in
  Then I see 7 pins

  When I select layer structures "All"
  Then I see 15 pins

  Then I select layer outline "Labels"
  Then I wait
