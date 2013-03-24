# Capistrano [![Build Status](https://travis-ci.org/capistrano/capistrano.png?branch=v3)](https://travis-ci.org/capistrano/capistrano)

wip - aim here is to get 'something' up and running

TODO:

  - [x] harness rake for dsl
  - [x] create a working capify equivalent
    - [x] create Capfile
    - [x] create lib/tasks/deploy
    - [x] create config/deploy/
    - [x] write config/deploy.rb with example configuration

  - [x] basic configuration object
  - [x] basic 'capistrano/deploy' noop example

  - [x] before/after task hooks
  - [x] handle multi stage
  - [x] pass any necessary configuration from deploy.rb to SSHKit

  - [x] support set/fetch/role configuration
  - [x] basic deploy
  - [x] ask
  - [x] add `deploy:check`
  - [x] prefer `roles(:all)` over `all_roles`
  - [x] simplify default deploy
  - [x] support setting default environment variables
  - [x] support existing significant configuration variables
  - [x] set configuration defaults, add commented out examples to templates
  - [x] basic rollback
  - [x] support primary servers `on primary :db`
  - [x] rails specific tasks (see [here](https://github.com/seenmyfate/capistrano-rails))
  - [x] auto load tasks for scm based on variable
  - [ ] run locally
  - [ ] better descriptions for tasks
  - [ ] add examples to README
  - [ ] add task packaging run through

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano', github: 'capistrano/capistrano', branch: :v3

And then execute:

    $ bundle --binstubs

Capify:

    $ cap install

This creates the following files:

- `Capfile`
- `lib/deploy/tasks`
- `config/deploy/staging.rb`
- `config/deploy/production.rb`

To create different stages:

    $ cap install STAGES=local,sandbox,qa,production

## Usage

    $ cap -vT

    $ cap staging deploy
    $ cap production deploy

    $ cap production deploy --dry-run
    $ cap production deploy --prereqs

## Configuration

    # config/deploy.rb
    set :application, 'example app'

    # config/deploy/production.rb
    set :stage, :production

    ask :branch, :master

    role :app, %w{example.com example2.com}
    role :web, %w{example.com}
    role :db, %w{example.com}

    # the first server in the array is considered primary

## Tasks

## Before / After

Where calling on the same task name, executed in order of inclusion


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

## Console

Execute arbitrary remote commands

    $ cap staging console

## Configuration


## SSHKit



