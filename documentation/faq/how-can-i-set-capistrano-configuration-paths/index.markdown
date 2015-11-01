---
title: How can I set Capistrano configuration paths?
layout: default
---

Capistrano `config` and `tasks` paths can be explicitly defined, like so:

Capfile

```ruby
# default deploy_config_path is 'config/deploy.rb'
set :deploy_config_path, 'cap/deploy.rb'
# default stage_config_path is 'config/deploy'
set :stage_config_path, 'cap/stages'

# previous variables MUST be set before 'capistrano/setup'
require 'capistrano/setup'

# default tasks path is `lib/capistrano/tasks/*.rake` 
# (note that you can also change the file extensions)
Dir.glob('cap/tasks/*.rb').each { |r| import r }
```

Here is the corresponding capistrano configuration structure:

```bash
├── Capfile
└── cap
    ├── stages
    │   ├── production.rb
    │   └── staging.rb
    ├── tasks
    │   └── custom_tasks.rb
    └── deploy.rb
```

<div class="alert-box alert">
Be aware that you will have to provide an absolute path, if you want your "deploy_config_path" to be "capistrano/deploy.rb".
See <a href="https://github.com/capistrano/capistrano/issues/1519#issuecomment-152357282">this issue</a> for more explanations and how to get an absolute path in Ruby.
</div>
