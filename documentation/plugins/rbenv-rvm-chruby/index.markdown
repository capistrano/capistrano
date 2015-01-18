---
title: rbenv & RVM & Chruby
layout: default
---

Capistrano 3 comes with official support of most common ruby version managers: rbenv, RVM and Chruby.

Basic installation includes `require 'capistrano/rbenv'` (or `capistrano/rvm` / `capistrano/chruby`) and defining `set :rbenv_ruby_version, '2.0.0-p247'`, or `rvm_ruby_version` / `chruby_ruby`.

Capistrano is not taking responsibility to install rubies, so on the servers you are deploying to, you will have to manually install the proper ruby and (optionally) create the gemset.

Check README of each gem if you want to customize other options like user or system-wide installation type.

<div class="github-widget" data-repo="capistrano/rbenv"></div>
<div class="github-widget" data-repo="capistrano/rvm"></div>
<div class="github-widget" data-repo="capistrano/chruby"></div>

