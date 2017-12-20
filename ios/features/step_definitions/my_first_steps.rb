Given /^I am on the Home Screen$/ do
  check_element_exists("view:'HumanOverlay'")
  sleep(STEP_PAUSE)
end

Given /^I am on image "(\d+)\.(\d+)"$/ do |chapterNumber,imageNumber|
  macro 'I am on the Home Screen'
  macro 'I touch chapter %03d' % chapterNumber
  macro 'I open image %d.%d' % [chapterNumber, imageNumber]
  macro 'caption contains " %d.%d "' % [chapterNumber, imageNumber]
end

Given /^I open legend$/ do
  if query("view:'MHPagingScrollView'", "delegate", "displayCaption")[0] == "0"
    touch("view marked:'caption'")
    sleep(STEP_PAUSE)
  end
end


When /^I touch chapter (\d+)$/ do |chapterNumber|
  touch("view:'HumanOverlay' marked:'chp#{chapterNumber}_000'")
  sleep(STEP_PAUSE)
end


When /^I open image (\d+\.\d+)$/ do |imageNumber|
  wait_for(:retry_frequency => 1) do
    if not query("view:'ImageGridCell' label {text CONTAINS ' #{imageNumber} '}").empty?
      true
    else
      scroll "scrollView", :down
      false
    end
  end
  touch("view:'ImageGridCell' label {text CONTAINS ' #{imageNumber} '}")
  wait_for_none_animating()
  sleep(STEP_PAUSE)
end

When /^I swipe to next image$/ do
  scroll('scrollView', 'right')
  sleep(STEP_PAUSE*2)
end

When /^I touch in the middle of the screen$/ do
  # currently this is just SOMEWHERE in the middle ..
  touch(nil, { :offset => {:x => 400, :y => 200} })
  sleep(STEP_PAUSE)
end
Given "mini gallery is closed" do
  if not query("view:'ThumbScrollView'").empty?
    touch(nil, { :offset => {:x => 200, :y => 200} })
    wait_for_elements_do_not_exist(["view:'ThumbScrollView'"])
    sleep(STEP_PAUSE);
  end
end

When "I open the mini gallery" do
  # TODO make sure mini gallery is not open
  touch(nil, { :offset => {:x => 200, :y => 200} })
  # TODO make sure mini gallery has opened.
  wait_for_elements_exist(["view:'ThumbScrollView'"])
end


Then /^I see image cell "(.*?)"$/ do |label|
  check_element_exists("view:'ImageGridCell' label {text CONTAINS '#{label}'}")
end

Then /^I touch thumbnail "(.*?)"$/ do |thumb|
  # if it is not imediately visible, we try to scroll to the right..
  wait_for(:retry_frequency => 1) do
    if query("view marked:'#{thumb}'").length > 0
      true
    else
      scroll("view:'ThumbScrollView'", :right)
      false
    end
  end
  touch("view marked:'#{thumb}'")
  sleep(STEP_PAUSE);
end

#When /^I press back$/ do
#  touch("button marked:'Back'")
#end

Then /^caption contains "(.*)"$/ do |label|
  #check_element_exists("view marked:'caption' {text CONTAINS '#{label}'}")
  wait_for(:retry_frequency => 1, :timeout => 3) do
    caption = query("view marked:'caption'", :text)[0]
    caption.include?(label)
    
  end
  #assert caption.include?(label), "caption: #{caption}"
end


When /^I select layer outline "(.*?)"$/ do |type|
  tmp = { "Pins" => 0, "Labels" => 1, "Image" => 2 }
  macro 'I touch "layermenu"'
  macro 'I wait to see "Outline Selector"'
  macro "I touch \"#{type}\""
  touch("view marked:'Outline Selector' segment index:#{tmp[type]}")
  if is_ipad()
    puts "is ipad."
    macro 'I touch in the middle of the screen'
  else
    puts "is iphone."
    macro 'I press "back"'
  end
  wait_for_none_animating()
end

When /^I select layer structures "(.*?)"$/ do |type|
  tmp = { "Important" => 0, "All" => 1 }
  macro 'I touch "layermenu"'
  macro 'I wait to see "Structure Selector"'
  touch("view marked:'Structure Selector' segment index:#{tmp[type]}")
  macro "I touch \"#{type}\""
  if is_ipad()
    puts "is ipad."
    macro 'I touch in the middle of the screen'
  else
    puts "is iphone."
    macro 'I press "back"'
  end
  wait_for_none_animating()
end

When /^I switch index to "(.*?)"$/ do |type|
  tmp = { "Structures" => 1 }
  touch("tabBar tabBarButton index:1")
end

Then /^I see (\d+) pins$/ do |pincount|
  wait_for(:retry_frequency => 1, :timeout => 3) do
    puts "I see %d pins\n" % query("view:'NAPinAnnotationView'").length
    query("view:'NAPinAnnotationView'").length == Integer(pincount)
  end
end

Then /^I pinch to zoom image in$/ do
  playback "pinchimage_in"
end



