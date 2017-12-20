Then /^I search for "(.*?)"$/ do |term|
  touch("searchBar")
  keyboard_enter_text(term)
  sleep(STEP_PAUSE*2)
end

Then /^I clear search$/ do
  touch("searchBar button")
end

