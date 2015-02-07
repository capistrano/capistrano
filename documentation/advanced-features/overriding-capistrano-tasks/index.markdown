---
title: Overriding Capistrano tasks
layout: default
---

When re-defining a task in Capistrano v2, the original task was replaced. The
Rake DSL on which Capistrano v3 is built is additive however, which means that
given the following definitions

```ruby
task :foo do
    puts "foo"
end

task :foo do
    puts "bar"
end
```

Will print both `foo` and `bar`.

But it is also possible to completely clear a task and then re-defining it
from scratch. A `Rake::Task` provides the `clear` method for this, which
internally performs three separate actions:

- `clear_prerequisites`
- `clear_actions`
- `clear_comments`

Clearing the prerequisites (i.e. any dependencies that may have been defined
for a task) is probably not what you want, though. Let's say, for example,
that you want to re-define the `deploy:revert_release` task, which is defined
as follows:

```ruby
task :revert_release => :rollback_release_path do
    # ...
end
```

Calling `clear` on this task and then re-defining it results in
`rollback_release_path` never being called, thus breaking rollback behavior.

Under most circumstances, you will simply want to use `clear_actions`, which
removes the specified task's behaviour, but does not alter it's dependencies
or comments:

```ruby
task :init do
    puts "init"
end

task :foo => :init do
    puts "foo"
end

Rake::Task["foo"].clear_actions
task :foo do
    puts "bar"
end
```

Running the `foo` task will print

```ruby
init
bar
```

---
