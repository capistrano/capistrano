---
title: Ruby on Rails
layout: default
---

**Note:** The Ruby on Rails tasks target the most recent Ruby on Rails
version, and as such might be unsuitable for you, please test these recipes in
your staging environment before deploying them to production!


### Capistrano::Rails

The official Gem for Capistrano-Rails is named `capistrano-rails`, and one can
simply define this in one's Rails project's `Gemfile`, it will depend on a
suitably new version of Capistrano.

The
[`README`](https://github.com/capistrano/rails/blob/master/README.md)
for the Capistrano::Rails explains more than enough, sufficed to say that it
adds appropriate hooks for database migrations and asset compilation at the
appropriate times.

<div class="github-widget" data-repo="capistrano/rails"></div>

