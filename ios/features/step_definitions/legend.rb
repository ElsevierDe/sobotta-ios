Then /^I touch in legend on link "(.*?)"$/ do |link|
  q = "webView css:'a' {textContent CONTAINS '#{link}'}"
  wait_for(:retry_frequency => 1) do
    if not query(q).empty?
      true
    else
      scroll "webView", :down
      false
    end
  end

  touch(q)
  sleep(STEP_PAUSE)

end

