---
title: Remote file task
layout: default
---

**Warning: `remote_file` is deprecated and will be removed in Capistrano 3.7.0**

The `remote_file` task is allowing the existence of a remote file to be set as a prerequisite. These tasks can in turn depend on local files if required. In this implementation, the fact that we're dealing with a file in the shared path is assumed.

As an example, this task can be used to ensure that files to be linked exist
before running the check:linked_files task:

```ruby
namespace :deploy do
  namespace :check do
    task :linked_files => 'config/newrelic.yml'
  end
end

remote_file 'config/newrelic.yml' => '/tmp/newrelic.yml', roles: :app

file '/tmp/newrelic.yml' do |t|
  sh "curl -o #{t.name} https://rpm.newrelic.com/accounts/xx/newrelic.yml"
end
```
