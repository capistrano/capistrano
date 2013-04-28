# Capistrano [![Build Status](https://travis-ci.org/capistrano/capistrano.png?branch=v3)](https://travis-ci.org/capistrano/capistrano)

TODO

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



