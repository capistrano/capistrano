# Capistrano

wip - aim here is to get 'something' up and running

TODO:

  - [x] harness rake for dsl
  - [x] create a working capify equivalent
    - [x] create Capfile
    - [x] create lib/tasks/deploy
    - [x] create config/deploy/
    - [x] write config/deploy.rb with example configuration

  - [x] basic configuration object
  - [x] pass any necessary configuration from deploy.rb to SSHKit
  - [x] basic 'capistrano/deploy' noop example
  - [x] don't care too much about testing at this point (rspec included for my reference)

  - [ ] before/after task hooks
  - [ ] consider requiring default tasks via configuration (strategy?) rather than Capfile
  - [ ] write more default tasks
  - [ ] handle multiple stage file generation

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano' github: 'capistrano/capistrano', branch: :wip

And then execute:

    $ bundle

Capify:

    $ bundle exec cap install

## Usage

    $ cap -vT

    $ cap deploy
