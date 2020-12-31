require "shellwords"

Then(/^references in the remote repo are listed$/) do
  expect(@output).to include("refs/heads/master")
end

Then(/^git wrapper permissions are 0700$/) do
  permissions_test = %Q([ $(stat -c "%a" #{TestApp.git_wrapper_path_glob}) == "700" ])
  _stdout, _stderr, status = vagrant_cli_command("ssh -c #{permissions_test.shellescape}")

  expect(status).to be_success
end

Then(/^the shared path is created$/) do
  run_vagrant_command(test_dir_exists(TestApp.shared_path))
end

Then(/^the releases path is created$/) do
  run_vagrant_command(test_dir_exists(TestApp.releases_path))
end

Then(/^(\d+) valid releases are kept/) do |num|
  test = %Q([ $(ls -g #{TestApp.releases_path} | grep -E '[0-9]{14}' | wc -l) == "#{num}" ])
  _, _, status = vagrant_cli_command("ssh -c #{test.shellescape}")
  expect(status).to be_success
end

Then(/^the invalid (.+) release is ignored$/) do |filename|
  test = "ls -g #{TestApp.releases_path} | grep #{filename}"
  _, _, status = vagrant_cli_command("ssh -c #{test.shellescape}")
  expect(status).to be_success
end

Then(/^directories in :linked_dirs are created in shared$/) do
  TestApp.linked_dirs.each do |dir|
    run_vagrant_command(test_dir_exists(TestApp.shared_path.join(dir)))
  end
end

Then(/^directories referenced in :linked_files are created in shared$/) do
  dirs = TestApp.linked_files.map { |path| TestApp.shared_path.join(path).dirname }
  dirs.each do |dir|
    run_vagrant_command(test_dir_exists(dir))
  end
end

Then(/^the repo is cloned$/) do
  run_vagrant_command(test_dir_exists(TestApp.repo_path))
end

Then(/^the release is created$/) do
  run_vagrant_command("ls -g #{TestApp.releases_path}")
end

Then(/^file symlinks are created in the new release$/) do
  TestApp.linked_files.each do |file|
    run_vagrant_command(test_symlink_exists(TestApp.current_path.join(file)))
  end
end

Then(/^directory symlinks are created in the new release$/) do
  pending
  TestApp.linked_dirs.each do |dir|
    run_vagrant_command(test_symlink_exists(TestApp.release_path.join(dir)))
  end
end

Then(/^the current directory will be a symlink to the release$/) do
  run_vagrant_command(exists?("e", TestApp.current_path))
end

Then(/^the deploy\.rb file is created$/) do
  file = TestApp.test_app_path.join("config/deploy.rb")
  expect(File.exist?(file)).to be true
end

Then(/^the default stage files are created$/) do
  staging = TestApp.test_app_path.join("config/deploy/staging.rb")
  production = TestApp.test_app_path.join("config/deploy/production.rb")
  expect(File.exist?(staging)).to be true
  expect(File.exist?(production)).to be true
end

Then(/^the tasks folder is created$/) do
  path = TestApp.test_app_path.join("lib/capistrano/tasks")
  expect(Dir.exist?(path)).to be true
end

Then(/^the specified stage files are created$/) do
  qa = TestApp.test_app_path.join("config/deploy/qa.rb")
  production = TestApp.test_app_path.join("config/deploy/production.rb")
  expect(File.exist?(qa)).to be true
  expect(File.exist?(production)).to be true
end

Then(/^it creates the file with the remote_task prerequisite$/) do
  TestApp.linked_files.each do |file|
    run_vagrant_command(test_file_exists(TestApp.shared_path.join(file)))
  end
end

Then(/^it will not recreate the file$/) do
  #
end

Then(/^the task is successful$/) do
  expect(@success).to be true
end

Then(/^the task fails$/) do
  expect(@success).to be_falsey
end

Then(/^the failure task will run$/) do
  failed = TestApp.shared_path.join("failed")
  run_vagrant_command(test_file_exists(failed))
end

Then(/^the failure task will not run$/) do
  failed = TestApp.shared_path.join("failed")
  expect { run_vagrant_command(test_file_exists(failed)) }
    .to raise_error(VagrantHelpers::VagrantSSHCommandError)
end

When(/^an error is raised$/) do
  error = TestApp.shared_path.join("fail")
  run_vagrant_command(test_file_exists(error))
end

Then(/contains "([^"]*)" in the output/) do |expected|
  expect(@output).to include(expected)
end

Then(/the output matches "([^"]*)" followed by "([^"]*)"/) do |expected, followedby|
  expect(@output).to match(/#{expected}.*#{followedby}/m)
end

Then(/doesn't contain "([^"]*)" in the output/) do |expected|
  expect(@output).not_to include(expected)
end

Then(/the current symlink points to the previous release/) do
  previous_release_path = @release_paths[-2]

  run_vagrant_command(symlinked?(TestApp.current_path, previous_release_path))
end

Then(/^the current symlink points to that specific release$/) do
  specific_release_path = TestApp.releases_path.join(@rollback_release)

  run_vagrant_command(symlinked?(TestApp.current_path, specific_release_path))
end
