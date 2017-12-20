Feature: Legends
    As a user I want to view legends of figures
    and follow links.


Scenario: Follow link in caption.
  Given I am on image "3.34"
    And I open legend
  When I touch in legend on link "Fig. 3.31"
  Then caption contains " 3.31 "

  Then I wait

