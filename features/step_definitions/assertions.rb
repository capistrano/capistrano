Then(/^references in the remote repo are listed$/) do
end

Then(/^the shared path is created$/) do
  run_vagrant_command(test_dir_exists(TestApp.shared_path))
end

Then(/^the releases path is created$/) do
  run_vagrant_command(test_dir_exists(TestApp.releases_path))
end

Then(/^directories in :linked_dirs are created in shared$/) do
  TestApp.linked_dirs.each do |dir|
    run_vagrant_command(test_dir_exists(TestApp.shared_path.join(dir)))
  end
end

Then(/^directories referenced in :linked_files are created in shared$/) do
  dirs = TestApp.linked_files.map { |path| TestApp.shared_path.join(path).dirname }
  dirs.each do | dir|
    run_vagrant_command(test_dir_exists(dir))
  end
end

Then(/^the task will be successful$/) do
end


Then(/^the task will exit$/) do
end

Then(/^the repo is cloned$/) do
  run_vagrant_command(test_dir_exists(TestApp.repo_path))
end

Then(/^the release is created$/) do
  run_vagrant_command("ls -g #{TestApp.releases_path}")
end

Then(/^file symlinks are created in the new release$/) do
  pending
  TestApp.linked_files.each do |file|
    run_vagrant_command(test_symlink_exists(TestApp.release_path.join(file)))
  end
end

Then(/^directory symlinks are created in the new release$/) do
  pending
  TestApp.linked_dirs.each do |dir|
    run_vagrant_command(test_symlink_exists(TestApp.release_path.join(dir)))
  end
end

Then(/^the current directory will be a symlink to the release$/) do
  run_vagrant_command(test_symlink_exists(TestApp.current_path))
end

Then(/^the deploy\.rb file is created$/) do
  file = TestApp.test_app_path.join('config/deploy.rb')
  expect(File.exists?(file)).to be_true
end

Then(/^the default stage files are created$/) do
  staging = TestApp.test_app_path.join('config/deploy/staging.rb')
  production = TestApp.test_app_path.join('config/deploy/production.rb')
  expect(File.exists?(staging)).to be_true
  expect(File.exists?(production)).to be_true
end

Then(/^the tasks folder is created$/) do
  path = TestApp.test_app_path.join('lib/capistrano/tasks')
  expect(Dir.exists?(path)).to be_true
end

Then(/^the specified stage files are created$/) do
  qa = TestApp.test_app_path.join('config/deploy/qa.rb')
  production = TestApp.test_app_path.join('config/deploy/production.rb')
  expect(File.exists?(qa)).to be_true
  expect(File.exists?(production)).to be_true
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
  expect(@success).to be_true
end

Then(/^the failure task will run$/) do
  failed = TestApp.shared_path.join('failed')
  run_vagrant_command(test_file_exists(failed))
end

Then(/^the failure task will not run$/) do
  failed = TestApp.shared_path.join('failed')
  !run_vagrant_command(test_file_exists(failed))
end

When(/^an error is raised$/) do
  error = TestApp.shared_path.join('fail')
  run_vagrant_command(test_file_exists(error))
end
