Then /^I switch language to "(.*)"$/ do |lang|
  reallang = query("view marked:'language switcher' label", "text")[0]
  if reallang != lang
    touch("view marked:'language switcher'")
    sleep(STEP_PAUSE)
    touch("view marked:'switch-#{lang}'")
    sleep(STEP_PAUSE)
  end
end

Then /^I switch language to "(.*)" on homescreen$/ do |lang|
  if is_ipad()
    macro "I switch language to \"#{lang}\""
  else
    macro "I touch chapter 001"
    macro "I switch language to \"#{lang}\""
    macro 'I press "home"'
  end
end
