# Capistrano

wip - aim here is to get 'something' up and running

Initial goals:

  - harness rake for dsl
  - create a working capify equivalent
    - create Capfile
    - create lib/tasks/deploy
    - create config/deploy/
    - write config/deploy.rb with example configuration

  - basic configuration object
  - basic 'capistrano/rails' example to allow testing with real apps, helping to flush out requirements
  - don't care too much about testing at this point (rspec included for my reference)


## Installation

Add this line to your application's Gemfile:

    gem 'capistrano'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano

Capify:

    $ cap install

## Usage

    $ cap -vT

    $ cap deploy
