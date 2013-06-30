---
layout: default
title: A remote server automation and deployment tool written in Ruby.
---

### A Simple Task

{% prism ruby %}
role :demo, %w{example.com example.org, example.net}
task :uptime do |host|
  on :demo, in: :parallel do
    uptime = capture(:uptime)
    puts "#{host.hostname} reports: #{uptime}"
  end
end
{% endprism %}

Capistrano extends the *Rake* DSL with methods specific to running commands
`on()` servers.

### For Any Language

Capistrano is written in Ruby, but it can easily be used to deploy any
language. Popular extensions add support for *Wordpress* blogs as well as
*Symfony* and *Node.js* applications.

If your language has special deployment requirements, Capistrano can easily be
extended to support them.

### Demo Video

<video id="demo" class="video-js vjs-default-skin" controls preload="auto" width="640" height="400" data-setup="{}">
  <source src="http://capistrano-screencasts.s3.amazonaws.com/Capistrano%20Introduction%20Video.mp4" type='video/mp4'>
</video>

### Source Code

<div class="github-widget" data-repo="capistrano/capistrano"></div>
<div class="github-widget" data-repo="capistrano/rails"></div>
<div class="github-widget" data-repo="capistrano/documentation"></div>
