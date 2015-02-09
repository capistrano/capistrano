---
title: Before / After Hooks
layout: default
---

Where calling on the same task name, executed in order of inclusion

```ruby
# call an existing task
before :starting, :ensure_user

after :finishing, :notify


# or define in block
before :starting, :ensure_user do
  #
end

after :finishing, :notify do
  #
end
```

If it makes sense for your use case (often, that means *generating a file*)
the Rake prerequisite mechanism can be used:

```ruby
desc "Create Important File"
file 'important.txt' do |t|
  sh "touch #{t.name}"
end
desc "Upload Important File"
task :upload => 'important.txt' do |t|
  on roles(:all) do
    upload!(t.prerequisites.first, '/tmp')
  end
end
```

The final way to call out to other tasks is to simply `invoke()` them:

```ruby
namespace :example do
  task :one do
    on roles(:all) { info "One" }
  end
  task :two do
    invoke "example:one"
    on roles(:all) { info "Two" }
  end
end
```

This method is widely used.
