Given(/^a test app with the default configuration$/) do
  TestApp.install
end

Given(/^servers with the roles app and web$/) do
  vagrant_cli_command('up')
end

Given(/^a required file$/) do
end

Given(/^that file exists$/) do
  run_vagrant_command("touch #{TestApp.linked_file}")
end

Given(/^the file does not exist$/) do
  pending
  file = TestApp.linked_file
  run_vagrant_command("[ -f #{file} ] && rm #{file}")
end

Given(/^a custom task to generate a file$/) do
  TestApp.copy_task_to_test_app('spec/support/tasks/database.cap')
end

Given(/^the configuration is in a custom location$/) do
  TestApp.move_configuration_to_custom_location('app')
end

Given(/^a custom task that will simulate a failure$/) do
  safely_remove_file(TestApp.shared_path.join('failed'))
  TestApp.copy_task_to_test_app('spec/support/tasks/fail.cap')
end

Given(/^a custom task to run in the event of a failure$/) do
  safely_remove_file(TestApp.shared_path.join('failed'))
  TestApp.copy_task_to_test_app('spec/support/tasks/failed.cap')
end
