Given(/^a test app with the default configuration$/) do
  TestApp.install
end

Given(/^servers with the roles app and web$/) do
  begin
    vagrant_cli_command("up")
  rescue
    nil
  end
end

Given(/^a linked file "(.*?)"$/) do |file|
  # ignoring other linked files
  TestApp.append_to_deploy_file("set :linked_files, ['#{file}']")
end

Given(/^file "(.*?)" exists in shared path$/) do |file|
  file_shared_path = TestApp.shared_path.join(file)
  run_vagrant_command("mkdir -p #{TestApp.shared_path}")
  run_vagrant_command("touch #{file_shared_path}")
end

Given(/^file "(.*?)" does not exist in shared path$/) do |file|
  file_shared_path = TestApp.shared_path.join(file)
  run_vagrant_command("mkdir -p #{TestApp.shared_path}")
  run_vagrant_command("touch #{file_shared_path} && rm #{file_shared_path}")
end

Given(/^a custom task to generate a file$/) do
  TestApp.copy_task_to_test_app("spec/support/tasks/database.rake")
end

Given(/^a task which executes as root$/) do
  TestApp.copy_task_to_test_app("spec/support/tasks/root.rake")
end

Given(/config stage file has line "(.*?)"/) do |line|
  TestApp.append_to_deploy_file(line)
end

Given(/^the configuration is in a custom location$/) do
  TestApp.move_configuration_to_custom_location("app")
end

Given(/^a custom task that will simulate a failure$/) do
  safely_remove_file(TestApp.shared_path.join("failed"))
  TestApp.copy_task_to_test_app("spec/support/tasks/fail.rake")
end

Given(/^a custom task to run in the event of a failure$/) do
  safely_remove_file(TestApp.shared_path.join("failed"))
  TestApp.copy_task_to_test_app("spec/support/tasks/failed.rake")
end

Given(/^a stage file named (.+)$/) do |filename|
  TestApp.write_local_stage_file(filename)
end
