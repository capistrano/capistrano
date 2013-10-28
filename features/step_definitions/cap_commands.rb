When(/^I run cap "(.*?)"$/) do |task|
  TestApp.cap(task)
end

When(/^I run cap "(.*?)" as part of a release$/) do |task|
  TestApp.cap("deploy:new_release_path #{task}")
end

When(/^I run cap "(.*?)" and it fails$/) do |task|
  TestApp.copy_task_to_test_app('spec/support/tasks/deploy_failure.cap')
  TestApp.cap(task)
end

Then(/^deploy:failed is invoked$/) do
  Dir.chdir(TestApp.task_dir) do
    file = 'FAILED'

    output = %x[#{test_file_exists(file)}]
    %x[rm -f #{file}]
    expect(output).to match(/exists\.$/)
  end
end
