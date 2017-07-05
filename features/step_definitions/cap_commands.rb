When(/^I run cap "(.*?)"$/) do |task|
  @success, @output = TestApp.cap(task)
end

When(/^I run cap "(.*?)" within the "(.*?)" directory$/) do |task, directory|
  @success, @output = TestApp.cap(task, directory)
end

When(/^I run cap "(.*?)" as part of a release$/) do |task|
  TestApp.cap("deploy:new_release_path #{task}")
end

When(/^I run "(.*?)"$/) do |command|
  @success, @output = TestApp.run(command)
end

When(/^I rollback to a specific release$/) do
  @rollback_release = @release_paths.first.split("/").last

  step %Q{I run cap "deploy:rollback ROLLBACK_RELEASE=#{@rollback_release}"}
end
