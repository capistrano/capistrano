When(/^I run cap "(.*?)"$/) do |task|
  @success = TestApp.cap(task)
end

When(/^I run cap "(.*?)" as part of a release$/) do |task|
  TestApp.cap("deploy:new_release_path #{task}")
end

When(/^I run "(.*?)"$/) do |command|
  @success = TestApp.run(command)
end

