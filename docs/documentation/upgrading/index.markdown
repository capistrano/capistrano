---
title: "Upgrading from v2.x.x"
layout: default
---

1.
Update your Gemfile: `gem 'capistrano', '~> 3.0', require: false, group: :development`


If you deploy Rails, you wil also need `capistrano-rails` and `capistrano-bundler` gems (Rails and Bundler integrations were moved out from Capistrano 3).

```ruby
group :development do
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
end
```

  You can add idiomatic support for your preferred ruby version manager: rvm, rbenv, chruby.

```ruby
group :development do
  gem 'capistrano-rvm',   '~> 0.1', require: false
  gem 'capistrano-rbenv', '~> 2.0', require: false
  gem 'capistrano-chruby', github: 'capistrano/chruby', require: false
end
```

2.
We recommend to capify the project from scratch and move definitions from old to new configs then.

```bash
mkdir old_cap
mv Capfile old_cap
mv config/deploy.rb old_cap
mv config/deploy/ old_cap # --> only for multistage setups
```

It's time to capify:

```bash
cap install
```

3.
Capistrano 3 is multistage by default, so you will have `config/deploy/production.rb` and `config/deploy/staging.rb` right after capifying.
  If you need only one stage, remove these files and declare stage (for example `production`) and servers in `config/deploy.rb`.

4.
Update `config/deploy/production.rb` and `config/deploy/staging.rb` to have relevant data there. You may also want to add more stages from old configs (`old_cap/deploy/`).

5.
If you had a gateway server set doing `set :gateway, "www.capify.org"` you should upgrade to

```ruby
require 'net/ssh/proxy/command'

set :ssh_options, proxy: Net::SSH::Proxy::Command.new('ssh mygateway.com -W %h:%p')
```

Or the per-server `ssh_options` equivalent.

6.
Now you need to refactor your old `deploy.rb` (also `Capfile`, but in most of cases developers didn't change it in Capistrano 2.x). Move parameters (like `set :deploy_to, "/home/deploy/#{application}"` or `set :keep_releases, 4`) to `config/deploy.rb` and tasks to `Capfile`.

*Important: `repository` option was renamed to `repo_url`; `default_environment` option was renamed to `default_env`.*

Notice that some parameters are not necessary anymore: `use_sudo`, `normalize_asset_timestamps`.

7.
If you didn't use `deploy_to` before and deployed to `/u/apps/your_app_name`, you need one more change. Now default deploy path is `/var/www/app_name` and your config will be broken after upgrade. Just declare custom `deploy_to` option:

```ruby
set :deploy_to, "/u/apps/#{fetch(:application)}"
```

But in advance, `/u/apps` is not the best place to store apps and we advice you to change it later.

8.
Keep editing Capfile and uncomment addons you need, such as rbenv/rvm, bundler or rails.

```ruby
require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/rbenv'
```

9.
Yay! Try to deploy with your new config set. If you discover any missing info in this upgrade guide, you're welcome to contribute to it.

# General recommendations

#### Use DSL instead of writing ENV variables

Instead of:

```ruby
run <<-CMD.compact
  cd -- #{latest_release} &&
  RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} #{rake} assets:precompile
CMD
```

It's better to use:

```ruby
on roles :all do
  within fetch(:latest_release_directory) do
    with rails_env: fetch(:rails_env) do
      execute :rake, 'assets:precompile'
    end
  end
end
```

Note: 'within' blocks are required to be wrapped in an 'on' block for the dsl to recognize it

You may only have one 'with' block per call. If you need more than one env set, use the syntax in the 'with' block arg like this (pass it a map):

```ruby
on roles :all do
  within fetch(:latest_release_directory) do
    with rails_env: fetch(:rails_env), rails_relative_url_root: '/home' do
      execute :rake, 'assets:precompile', env: {rails_env: fetch(:rails_env), rails_relative_url_root: ''}
    end
  end
end
```

# Notable differences between 2.x and 3

#### Cleanup

Capistrano 3 now runs the `deploy:cleanup` task as part of the standard deploy workflow and keeps 5 releases by default. Previously this was left for you to add manually, if required. To change the number of releases kept set the `keep_releases` configuration variable:

```ruby
set :keep_releases, 10
```
