---
title: Passenger
layout: default
---

Capistrano 3 does not restart your application by default.  You need to add a task to do this `after deploy:publishing`.
If you're using passenger, this gem has you covered.  All you need to do is `require 'capistrano/passenger' in your Capfile.
Checkout the README to learn how to customize the timing of restarts. By default, the deployment will wait 5 seconds between server restarts so all your servers don't shut off at once.

<div class="github-widget" data-repo="capistrano/passenger"></div>

