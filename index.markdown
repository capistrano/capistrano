---
layout: default
title: A remote server automation and deployment tool written in Ruby.
---

### A Simple Task

{% prism ruby %}
role :demo, %w{example.com example.org example.net}
task :uptime do |host|
  on roles(:demo), in: :parallel do
    uptime = capture(:uptime)
    puts "#{host.hostname} reports: #{uptime}"
  end
end
{% endprism %}

Capistrano extends the *Rake* DSL with methods specific to running commands
`on()` servers.

### For Any Language

Capistrano is written in Ruby, but it can easily be used to deploy any
language.

If your language or framework has special deployment requirements, Capistrano can easily be
extended to support them.

### Source Code

<div class="github-widget" data-repo="capistrano/capistrano"></div>
<div class="github-widget" data-repo="capistrano/rails"></div>
<div class="github-widget" data-repo="capistrano/documentation"></div>
