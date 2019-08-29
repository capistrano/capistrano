Given(/^a test app with the default configuration$/) do
  TestApp.install
end

Given(/^a test app without any configuration$/) do
  TestApp.create_test_app
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
  run_vagrant_command("mkdir -p #{file_shared_path.dirname}")
  run_vagrant_command("touch #{file_shared_path}")
end

Given(/^all linked files exists in shared path$/) do
  TestApp.linked_files.each do |linked_file|
    step %Q{file "#{linked_file}" exists in shared path}
  end
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

Given(/^I make (\d+) deployments$/) do |count|
  step "all linked files exists in shared path"

  @release_paths = (1..count.to_i).map do
    TestApp.cap("deploy")
    stdout, _stderr = run_vagrant_command("readlink #{TestApp.current_path}")

    stdout.strip
  end
end

Given(/^(\d+) valid existing releases$/) do |num|
  a_day = 86_400 # in seconds
  (1...num).each_slice(100) do |num_batch|
    dirs = num_batch.map do |i|
      offset = -(a_day * i)
      TestApp.release_path(TestApp.timestamp(offset))
    end
    run_vagrant_command("mkdir -p #{dirs.join(' ')}")
  end
end

Given(/^an invalid release named "(.+)"$/) do |filename|
  run_vagrant_command("mkdir -p #{TestApp.release_path(filename)}")
end
