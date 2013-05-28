# Capistrano [![Build Status](https://travis-ci.org/capistrano/capistrano.png?branch=v3)](https://travis-ci.org/capistrano/capistrano)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'capistrano', github: 'capistrano/capistrano', branch: :v3
```

And then execute:

``` ruby
$ bundle --binstubs
```

Capify:

``` shell
$ cap install
```

This creates the following files:

```
├── Capfile
├── config
│   ├── deploy
│   │   ├── production.rb
│   │   └── staging.rb
│   └── deploy.rb
└── lib
    └── capistrano
            └── tasks
```

To create different stages:

``` shell
$ cap install STAGES=local,sandbox,qa,production
```

## Usage

``` shell
$ cap -vT

$ cap staging deploy
$ cap production deploy

$ cap production deploy --dry-run
$ cap production deploy --prereqs
$ cap production deploy --trace
```

## Tasks



## Before / After

Where calling on the same task name, executed in order of inclusion

``` ruby
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

## Console

Execute arbitrary remote commands, to use this simply add 
`require 'capistrano/console'` which will add the necessary tasks to your 
environment:

``` shell
$ cap staging console
```

## Configuration


## SSHKit